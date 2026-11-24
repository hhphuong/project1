package com.project.app.service;

import com.project.app.common.exception.ResourceNotFoundException;
import com.project.app.dto.request.ProductRequest;
import com.project.app.dto.response.ProductResponse;
import com.project.app.entity.Product;
import com.project.app.mapper.ProductMapper;
import com.project.app.repository.ProductRepository;
import com.project.app.service.impl.ProductServiceImpl;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProductServiceImplTest {

    @Mock
    private ProductRepository productRepository;

    @Spy
    private ProductMapper productMapper = new ProductMapper();

    @InjectMocks
    private ProductServiceImpl productService;

    @Test
    void getById_shouldReturnProduct_whenFound() {
        Product product = Product.builder()
                .name("Mechanical Keyboard")
                .description("Wireless RGB")
                .price(new BigDecimal("1500000.00"))
                .quantity(10)
                .active(true)
                .build();
        product.setId(1L);

        when(productRepository.findById(1L)).thenReturn(Optional.of(product));

        ProductResponse response = productService.getById(1L);

        assertThat(response.getId()).isEqualTo(1L);
        assertThat(response.getName()).isEqualTo("Mechanical Keyboard");
        assertThat(response.getPrice()).isEqualByComparingTo("1500000.00");
    }

    @Test
    void getById_shouldThrowResourceNotFoundException_whenMissing() {
        when(productRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> productService.getById(99L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("Product not found with id : '99'");
    }

    @Test
    void create_shouldSaveAndReturnMappedProduct() {
        ProductRequest request = ProductRequest.builder()
                .name("USB-C Hub")
                .description("7-in-1 Adapter")
                .price(new BigDecimal("850000.00"))
                .quantity(15)
                .active(true)
                .build();

        when(productRepository.save(any(Product.class))).thenAnswer(invocation -> {
            Product saved = invocation.getArgument(0);
            saved.setId(10L);
            return saved;
        });

        ProductResponse response = productService.create(request);

        verify(productRepository).save(any(Product.class));
        assertThat(response.getId()).isEqualTo(10L);
        assertThat(response.getName()).isEqualTo("USB-C Hub");
        assertThat(response.getQuantity()).isEqualTo(15);
    }
}
