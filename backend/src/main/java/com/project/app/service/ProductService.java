package com.project.app.service;

import com.project.app.dto.request.ProductRequest;
import com.project.app.dto.response.ProductResponse;

import java.util.List;

public interface ProductService {

    List<ProductResponse> getAll(String keyword);

    ProductResponse getById(Long id);

    ProductResponse create(ProductRequest request);

    ProductResponse update(Long id, ProductRequest request);

    void delete(Long id);
}
