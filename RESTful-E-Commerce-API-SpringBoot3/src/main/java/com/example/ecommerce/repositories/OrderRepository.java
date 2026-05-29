package com.example.ecommerce.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.ecommerce.entities.Order;

public interface OrderRepository extends JpaRepository<Order, Long>{

	List<Order> findByClientIdOrderByMomentDesc(Long clientId);

}
