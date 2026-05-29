package com.example.ecommerce.resources.dto;

import java.util.ArrayList;
import java.util.List;

public class OrderCheckoutRequest {

	private Long clientId;
	private List<OrderCheckoutItemRequest> items = new ArrayList<>();

	public OrderCheckoutRequest() {
	}

	public Long getClientId() {
		return clientId;
	}

	public void setClientId(Long clientId) {
		this.clientId = clientId;
	}

	public List<OrderCheckoutItemRequest> getItems() {
		return items;
	}

	public void setItems(List<OrderCheckoutItemRequest> items) {
		this.items = items;
	}
}
