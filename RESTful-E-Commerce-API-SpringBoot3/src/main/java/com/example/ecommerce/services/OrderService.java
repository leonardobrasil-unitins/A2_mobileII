package com.example.ecommerce.services;

import java.time.Instant;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.ecommerce.entities.Order;
import com.example.ecommerce.entities.OrderItem;
import com.example.ecommerce.entities.Product;
import com.example.ecommerce.entities.User;
import com.example.ecommerce.entities.enums.OrderStatus;
import com.example.ecommerce.repositories.OrderItemRepository;
import com.example.ecommerce.repositories.OrderRepository;
import com.example.ecommerce.repositories.ProductRepository;
import com.example.ecommerce.repositories.UserRepository;
import com.example.ecommerce.resources.dto.OrderCheckoutItemRequest;
import com.example.ecommerce.resources.dto.OrderCheckoutRequest;
import com.example.ecommerce.services.exceptions.DatabaseException;
import com.example.ecommerce.services.exceptions.ResourceNotFoundException;

@Service
public class OrderService {
	
	@Autowired
	private OrderRepository repository;

	@Autowired
	private OrderItemRepository orderItemRepository;

	@Autowired
	private UserRepository userRepository;

	@Autowired
	private ProductRepository productRepository;
	
	public List<Order> findAll(){
		return repository.findAll();
	}

	public List<Order> findByClientId(Long clientId){
		return repository.findByClientIdOrderByMomentDesc(clientId);
	}
	
	public Order findById(Long id) {
		Optional<Order> order = repository.findById(id);
		return order.orElseThrow(() -> new ResourceNotFoundException(id));
	}

	@Transactional
	public Order insert(OrderCheckoutRequest request) {
		validateRequest(request);

		User client = userRepository.findById(request.getClientId())
				.orElseThrow(() -> new ResourceNotFoundException(request.getClientId()));

		Order order = new Order(null, Instant.now(), OrderStatus.WAITING_PAYMENT, client);
		order = repository.save(order);

		Set<OrderItem> orderItems = new HashSet<>();
		for (OrderCheckoutItemRequest itemRequest : request.getItems()) {
			Product product = productRepository.findById(itemRequest.getProductId())
					.orElseThrow(() -> new ResourceNotFoundException(itemRequest.getProductId()));

			OrderItem orderItem = new OrderItem(
					order,
					product,
					itemRequest.getQuantity(),
					product.getPrice());

			orderItems.add(orderItem);
		}

		order.getItems().addAll(orderItems);
		orderItemRepository.saveAll(orderItems);

		Long orderId = order.getId();
		return repository.findById(orderId)
				.orElseThrow(() -> new ResourceNotFoundException(orderId));
	}

	private void validateRequest(OrderCheckoutRequest request) {
		if (request == null) {
			throw new DatabaseException("The order request cannot be empty.");
		}

		if (request.getClientId() == null) {
			throw new DatabaseException("The order client is required.");
		}

		if (request.getItems() == null || request.getItems().isEmpty()) {
			throw new DatabaseException("The order must contain at least one item.");
		}

		for (OrderCheckoutItemRequest itemRequest : request.getItems()) {
			if (itemRequest.getProductId() == null) {
				throw new DatabaseException("Each order item must inform a product.");
			}

			if (itemRequest.getQuantity() == null || itemRequest.getQuantity() <= 0) {
				throw new DatabaseException("The item quantity must be greater than zero.");
			}
		}
	}

}
