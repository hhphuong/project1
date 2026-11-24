package com.project.app.service.impl;

import com.project.app.common.exception.ResourceNotFoundException;
import com.project.app.dto.request.ProductRequest;
import com.project.app.dto.response.ProductResponse;
import com.project.app.entity.Product;
import com.project.app.mapper.ProductMapper;
import com.project.app.repository.ProductRepository;
import com.project.app.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final ProductMapper productMapper;

    @Override
    public List<ProductResponse> getAll(String keyword) {
        List<Product> products = StringUtils.hasText(keyword)
                ? productRepository.findByNameContainingIgnoreCase(keyword.trim())
                : productRepository.findAll();

        return products.stream()
                .map(productMapper::toResponse)
                .toList();
    }

    @Override
    public ProductResponse getById(Long id) {
        Product product = findProductOrThrow(id);
        return productMapper.toResponse(product);
    }

    @Override
    @Transactional
    public ProductResponse create(ProductRequest request) {
        Product product = productMapper.toEntity(request);
        Product savedProduct = productRepository.save(product);
        return productMapper.toResponse(savedProduct);
    }

    @Override
    @Transactional
    public ProductResponse update(Long id, ProductRequest request) {
        Product existingProduct = findProductOrThrow(id);
        productMapper.updateEntity(existingProduct, request);
        Product updatedProduct = productRepository.save(existingProduct);
        return productMapper.toResponse(updatedProduct);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Product existingProduct = findProductOrThrow(id);
        productRepository.delete(existingProduct);
    }

    private Product findProductOrThrow(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product", "id", id));
    }
}
