<?php
// app/Http/Controllers/Api/CartController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\User;

use App\Models\Product;
use App\Models\Vendor;
use App\Models\VendorProduct;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CartController extends Controller
{
    /**
     * Get user's cart with all details
     */
 public function index(Request $request, $userId)
{
    try {
        // For testing - if no user is authenticated, use user_id from request
       // $user = $request->user();
        $user = $request->route('userId');
        if (!$user) {
            // If no authenticated user, check if user_id is provided in request
            if ($request->has('user_id')) {
                $userId = $request->user_id;
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated and no user_id provided'
                ], 401);
            }
        } else {
            $userId = $user->id;
        }
        
        $cartItems = Cart::withDetails()
            ->forUser($userId)
            ->get();

        $totalItems = $cartItems->sum('quantity');
        $totalAmount = $cartItems->sum('total');
        $selectedTotal = $cartItems->where('is_selected', true)->sum('total');

        // Group by vendor for better organization
        $groupedByVendor = $cartItems->groupBy('vendor_id')->map(function ($items, $vendorId) {

            $vendor = User::find($vendorId);
            return [
                'vendor_id' => $vendorId,
                'vendor_name' => $vendor->name ?? 'Unknown Vendor',
                'items' => $items,
                'subtotal' => $items->sum('total')
            ];
        })->values();

        return response()->json([
            'success' => true,
            'data' => [
                'items' => $cartItems,
                'grouped_by_vendor' => $groupedByVendor,
                'summary' => [
                    'total_items' => $totalItems,
                    'total_amount' => round($totalAmount, 2),
                    'selected_total' => round($selectedTotal, 2),
                    'item_count' => $cartItems->count()
                ]
            ],
            'message' => 'Cart retrieved successfully'
        ], 200);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Failed to retrieve cart',
            'error' => $e->getMessage()
        ], 500);
    }
}
  
  
  
  
  public function getUserCart($userId)
    {
        try {

            // Optional: Check if user exists
            $user = User::find($userId);

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not found'
                ], 404);
            }

            // Get cart items
           $cartItems = Cart::with([
        'vendor',
        'product.images'
    ])
    ->where('user_id', $userId)
    ->get();

            // Calculate totals
            $totalItems = $cartItems->sum('quantity');

            $totalAmount = $cartItems->sum(function ($item) {
                return $item->price * $item->quantity;
            });

            $selectedTotal = $cartItems
                ->where('is_selected', true)
                ->sum(function ($item) {
                    return $item->price * $item->quantity;
                });

            // Group by vendor
            $groupedByVendor = $cartItems->groupBy('vendor_id')->map(function ($items) {

                $vendor = $items->first()->vendor;

                return [
                    'vendor_id' => $vendor->id ?? null,
                    'vendor_name' => $vendor->name ?? 'Unknown Vendor',
                    'items' => $items,
                    'subtotal' => $items->sum(function ($item) {
                        return $item->price * $item->quantity;
                    }),
                ];
            })->values();

            return response()->json([
                'success' => true,
                'data' => [
                    'user_id' => $userId,
                    'items' => $cartItems,
                    'grouped_by_vendor' => $groupedByVendor,
                    'summary' => [
                        'total_items' => $totalItems,
                        'total_amount' => round($totalAmount, 2),
                        'selected_total' => round($selectedTotal, 2),
                        'item_count' => $cartItems->count(),
                    ],
                ],
                'message' => 'Cart retrieved successfully'
            ], 200);

        } catch (\Exception $e) {

            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve cart',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Add item to cart
     */
 public function store(Request $request)
{
    $validator = Validator::make($request->all(), [
        'user_id'    => 'required|exists:users,id',
        'product_id' => 'required|exists:products,id',
        'vendor_id'  => 'required|exists:users,id',
        'quantity'   => 'required|integer|min:1|max:100',
        'addon'      => 'nullable|integer|min:0', // ✅ optional addon qty
    ]);

    if ($validator->fails()) {
        return response()->json([
            'success' => false,
            'errors'  => $validator->errors()
        ], 422);
    }

    try {
        $userId = $request->user_id;

        // Check existing cart item
        $existingCart = Cart::where('user_id', $userId)
            ->where('product_id', $request->product_id)
            ->where('vendor_id', $request->vendor_id)
            ->first();

        if ($existingCart) {
            return $this->updateExistingCart($existingCart, $request->quantity);
        }

        // Get VendorProduct (if exists)
        $vendorProduct = VendorProduct::where([
                'product_id' => $request->product_id,
                'vendor_id'  => $request->vendor_id
            ])
            ->first();

        // Get price using your fallback logic
        $price = $this->getProductPrice($request);

        if ($price <= 0) {
            return response()->json([
                'success' => false,
                'message' => 'Product price not available'
            ], 400);
        }

        // Create cart
        $cartItem = Cart::create([
            'user_id'           => $userId,
            'product_id'        => $request->product_id,
            'vendor_id'         => $request->vendor_id,
            'vendor_product_id' => $vendorProduct?->id,
            'quantity'          => $request->quantity,
            'addon'             => $request->addon ?? 0, // ✅ insert addon
            'price'             => $price,
          	'mrp_price'			=> $mrpPrice,
          	'discount_min'		=> $discountMin,
          	'discount_max'		=> $discountMax,
            'total'             => $price * $request->quantity,
            'is_selected'       => true,
        ]);

        $cartItem->load(['product', 'vendor', 'vendorProduct']);

        return response()->json([
            'success' => true,
            'data'    => $cartItem,
            'message' => 'Item added to cart successfully'
        ], 201);

    } catch (\Exception $e) {
        \Log::error('Cart store error: ' . $e->getMessage());
        return response()->json([
            'success' => false,
            'message' => 'Failed to add item to cart'
        ], 500);
    }
}   /**
     * Update cart item quantity
     */
   public function update(Request $request, $id)
{
    try {
        // 🔥 DEBUG (check incoming data)
        \Log::info('Update Cart Request:', $request->all());

        // ✅ Find cart item
        $cartItem = Cart::findOrFail($id);

        // ✅ Update data (addon + quantity)
        $cartItem->update([
            'quantity' => $request->quantity,
            'addon' => (int) $request->addon, // ✅ Cast to integer
            'total' => $cartItem->price * $request->quantity
        ]);

        // ✅ Reload relations
        $cartItem->load(['product', 'vendor', 'vendorProduct']);

        return response()->json([
            'success' => true,
            'data' => $cartItem,
            'message' => 'Cart updated successfully'
        ], 200);

    } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
        return response()->json([
            'success' => false,
            'message' => 'Cart item not found'
        ], 404);

    } catch (\Exception $e) {
        // 🔥 DEBUG ERROR
        \Log::error('Cart Update Error:', [
            'error' => $e->getMessage()
        ]);

        return response()->json([
            'success' => false,
            'message' => 'Failed to update cart',
            'error' => $e->getMessage()
        ], 500);
    }
}
    /**
     * Toggle item selection
     */
    public function toggleSelection(Request $request, $id)
    {
        try {
            $cartItem = Cart::where('id', $id)
                ->where('user_id', $request->user()->id)
                ->firstOrFail();

            $cartItem->update([
                'is_selected' => !$cartItem->is_selected
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $cartItem->id,
                    'is_selected' => $cartItem->is_selected
                ],
                'message' => 'Selection updated'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update selection'
            ], 500);
        }
    }

    /**
     * Select/Deselect all items
     */
    public function selectAll(Request $request)
    {
        try {
            $selected = $request->selected ?? true;
            
            Cart::where('user_id', $request->user()->id)
                ->update(['is_selected' => $selected]);

            return response()->json([
                'success' => true,
                'message' => $selected ? 'All items selected' : 'All items deselected'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update selection'
            ], 500);
        }
    }

    /**
     * Remove item from cart
     */
 public function destroy($id)
{
    try {

        $cartItem = Cart::find($id);

        if (!$cartItem) {
            return response()->json([
                'success' => false,
                'message' => 'Cart item not found'
            ], 404);
        }

        $cartItem->delete();

        return response()->json([
            'success' => true,
            'message' => 'Item removed successfully'
        ], 200);

    } catch (\Exception $e) {

        return response()->json([
            'success' => false,
            'message' => 'Failed to remove item',
            'error' => $e->getMessage()
        ], 500);
    }
}



    /**
     * Clear entire cart
     */
    public function clear(Request $request)
    {
        try {
            Cart::where('user_id', $request->user()->id)->delete();

            return response()->json([
                'success' => true,
                'message' => 'Cart cleared successfully'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to clear cart'
            ], 500);
        }
    }

    /**
     * Get cart summary (for checkout)
     */
    public function summary(Request $request)
    {
        try {
            $selectedItems = Cart::withDetails()
                ->where('user_id', $request->user()->id)
                ->selected()
                ->get();

            if ($selectedItems->isEmpty()) {
                return response()->json([
                    'success' => false,
                    'message' => 'No items selected for checkout'
                ], 400);
            }

            $totalAmount = $selectedItems->sum('total');
            $totalItems = $selectedItems->sum('quantity');

            // Group by vendor for checkout
            $vendorGroups = $selectedItems->groupBy('vendor_id')->map(function($items, $vendorId) {
                $vendor = $items->first()->vendor;
                return [
                    'vendor_id' => $vendorId,
                    'vendor_name' => $vendor->name ?? 'Unknown Vendor',
                    'items' => $items->map(function($item) {
                        return [
                            'id' => $item->id,
                            'product_id' => $item->product_id,
                            'product_name' => $item->product->name,
                            'quantity' => $item->quantity,
                            'price' => $item->price,
                            'total' => $item->total
                        ];
                    }),
                    'subtotal' => $items->sum('total')
                ];
            })->values();

            return response()->json([
                'success' => true,
                'data' => [
                    'vendor_groups' => $vendorGroups,
                    'summary' => [
                        'total_items' => $totalItems,
                        'total_amount' => round($totalAmount, 2),
                        'vendor_count' => $vendorGroups->count()
                    ]
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get cart summary'
            ], 500);
        }
    }

    /**
     * Helper: Update existing cart item
     */
    private function updateExistingCart($cartItem, $additionalQuantity)
    {
        $newQuantity = $cartItem->quantity + $additionalQuantity;
        
        if ($newQuantity > 100) {
            return response()->json([
                'success' => false,
                'message' => 'Maximum quantity limit reached'
            ], 400);
        }

        $cartItem->update([
            'quantity' => $newQuantity,
            'total' => $cartItem->price * $newQuantity
        ]);

        $cartItem->load(['product', 'vendor', 'vendorProduct']);

        return response()->json([
            'success' => true,
            'data' => $cartItem,
            'message' => 'Cart updated successfully'
        ], 200);
    }

    /**
     * Helper: Get product price
     */
   private function getProductPrice($request)
{
    \Log::info('🔍 getProductPrice called with:', [
        'product_id' => $request->product_id,
        'vendor_id'  => $request->vendor_id
    ]);

    // 1️⃣ Try vendor product price
    $vendorProduct = VendorProduct::where('product_id', $request->product_id)
        ->where('vendor_id', $request->vendor_id)
        ->first();

    if ($vendorProduct) {
        \Log::info('📦 Vendor product found', $vendorProduct->toArray());

        if (!empty($vendorProduct->selling_price) && $vendorProduct->selling_price > 0) {
            \Log::info('✅ Using vendor price: ' . $vendorProduct->selling_price);
            return $vendorProduct->selling_price;
        }

        \Log::warning('⚠ Vendor price is zero or null. Falling back to product price.');
    } else {
        \Log::warning('⚠ Vendor product not found. Falling back to product price.');
    }

    // 2️⃣ Fallback to product table
    $product = Product::find($request->product_id);

    if ($product && !empty($product->price) && $product->price > 0) {
        \Log::info('✅ Using product base price: ' . $product->price);
        return $product->price;
    }

    \Log::error('❌ No valid price found for product ID: ' . $request->product_id);

    return 0;
}
  
  
  
  public function syncCart(Request $request)
{
    $validator = Validator::make($request->all(), [
        'user_id' => 'required|exists:users,id',
        'cart_items' => 'required|array',
        'cart_items.*.product_id' => 'required|exists:products,id',
        'cart_items.*.vendor_id' => 'required|exists:users,id',
        'cart_items.*.packing_id' => 'nullable|integer',
        'cart_items.*.packing_type' => 'nullable|string',
        'cart_items.*.quantity' => 'required|integer|min:1',
        'cart_items.*.price' => 'required|numeric|min:0',
    ]);

    if ($validator->fails()) {
        return response()->json([
            'success' => false,
            'errors' => $validator->errors()
        ], 422);
    }

    try {
        $userId = $request->user_id;
        $localCartItems = $request->cart_items;
        
        \Log::info('🔄 Starting cart sync for user: ' . $userId);
        \Log::info('📦 Local cart items to sync: ' . json_encode($localCartItems));
        
        $syncedItems = [];
        $failedItems = [];
        $skippedItems = [];

        foreach ($localCartItems as $item) {
            try {
                // Check if item already exists in server cart
                $existingCartItem = Cart::where('user_id', $userId)
                    ->where('product_id', $item['product_id'])
                    ->where('vendor_id', $item['vendor_id'])
                    ->first();

                // Get the correct vendor_product_id if available
                $vendorProductId = null;
                
                // Try to find vendor_product_id based on product and vendor
                $vendorProduct = VendorProduct::where('product_id', $item['product_id'])
                    ->where('vendor_id', $item['vendor_id'])
                    ->first();
                
                if ($vendorProduct) {
                    $vendorProductId = $vendorProduct->id;
                    
                    // Use the vendor product's selling price if available
                    if (isset($vendorProduct->selling_price) && $vendorProduct->selling_price > 0) {
                        $item['price'] = $vendorProduct->selling_price;
                    }
                }

                if ($existingCartItem) {
                    // Item exists - update quantity (merge)
                    $newQuantity = $existingCartItem->quantity + $item['quantity'];
                    
                    // Cap at maximum 100
                    if ($newQuantity > 100) {
                        $newQuantity = 100;
                        $skippedItems[] = [
                            'product_id' => $item['product_id'],
                            'reason' => 'Quantity limit reached (max 100)'
                        ];
                    }
                    
                    $existingCartItem->update([
                        'quantity' => $newQuantity,
                        'total' => $existingCartItem->price * $newQuantity,
                        'is_selected' => true,
                    ]);
                    
                    $existingCartItem->load(['product', 'vendor']);
                    $syncedItems[] = $existingCartItem;
                    
                    \Log::info('✅ Updated existing cart item for product: ' . $item['product_id'] . ' with quantity: ' . $newQuantity);
                    
                } else {
                    // New item - create
                    $price = $item['price'];
                    
                    // Verify price is valid
                    if ($price <= 0) {
                        // Try to get price from vendor product or product
                        if ($vendorProductId) {
                            $vendorProduct = VendorProduct::find($vendorProductId);
                            $price = $vendorProduct->selling_price ?? 0;
                        }
                        
                        if ($price <= 0) {
                            $product = Product::find($item['product_id']);
                            $price = $product->price ?? 0;
                        }
                    }
                    
                    // If still no valid price, skip this item
                    if ($price <= 0) {
                        $failedItems[] = [
                            'product_id' => $item['product_id'],
                            'reason' => 'Invalid price'
                        ];
                        \Log::warning('⚠️ Skipping item with invalid price for product: ' . $item['product_id']);
                        continue;
                    }
                    
                    $cartItem = Cart::create([
                        'user_id' => $userId,
                        'product_id' => $item['product_id'],
                        'vendor_id' => $item['vendor_id'],
                        'vendor_product_id' => $vendorProductId,
                        'quantity' => $item['quantity'],
                        'price' => $price,
                        'total' => $price * $item['quantity'],
                        'is_selected' => true,
                    ]);
                    
                    $cartItem->load(['product', 'vendor']);
                    $syncedItems[] = $cartItem;
                    
                    \Log::info('✅ Created new cart item for product: ' . $item['product_id']);
                }
                
            } catch (\Exception $e) {
                \Log::error('❌ Failed to sync item: ' . json_encode($item) . ' Error: ' . $e->getMessage());
                $failedItems[] = [
                    'product_id' => $item['product_id'],
                    'reason' => $e->getMessage()
                ];
            }
        }

        // Get updated cart summary
        $cartItems = Cart::with(['product', 'vendor'])
            ->where('user_id', $userId)
            ->get();

        $totalItems = $cartItems->sum('quantity');
        $totalAmount = $cartItems->sum('total');
        $selectedTotal = $cartItems->where('is_selected', true)->sum('total');

        // Group by vendor
        $groupedByVendor = $cartItems->groupBy('vendor_id')->map(function ($items, $vendorId) {
            $vendor = $items->first()->vendor;
            return [
                'vendor_id' => $vendorId,
                'vendor_name' => $vendor->name ?? 'Unknown Vendor',
                'items' => $items,
                'subtotal' => $items->sum('total')
            ];
        })->values();

        return response()->json([
            'success' => true,
            'data' => [
                'synced_items' => $syncedItems,
                'failed_items' => $failedItems,
                'skipped_items' => $skippedItems,
                'cart_summary' => [
                    'items' => $cartItems,
                    'grouped_by_vendor' => $groupedByVendor,
                    'summary' => [
                        'total_items' => $totalItems,
                        'total_amount' => round($totalAmount, 2),
                        'selected_total' => round($selectedTotal, 2),
                        'item_count' => $cartItems->count()
                    ]
                ]
            ],
            'message' => 'Cart synced successfully. ' . count($syncedItems) . ' items synced, ' . count($failedItems) . ' failed, ' . count($skippedItems) . ' skipped.'
        ], 200);

    } catch (\Exception $e) {
        \Log::error('Cart sync error: ' . $e->getMessage());
        
        return response()->json([
            'success' => false,
            'message' => 'Failed to sync cart',
            'error' => $e->getMessage()
        ], 500);
    }
}
  
  
  
  
  
  
  
  
}