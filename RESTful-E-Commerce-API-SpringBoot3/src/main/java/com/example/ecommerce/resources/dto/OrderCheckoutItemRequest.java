package com.example.ecommerce.resources.dto;

public class OrderCheckoutItemRequest {

	private Long productId;
	private Integer quantity;

	public OrderCheckoutItemRequest() {
	}

	public Long getProductId() {
		return productId;
	}

	public void setProductId(Long productId) {
		this.productId = productId;
	}

	public Integer getQuantity() {
		return quantity;
	}

	public void setQuantity(Integer quantity) {
		this.quantity = quantity;
	}
}
