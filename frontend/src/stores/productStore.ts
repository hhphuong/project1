import { ref } from 'vue';
import { defineStore } from 'pinia';
import { productApi } from '@/api/productApi';
import type { Product, ProductPayload } from '@/types/product';

export const useProductStore = defineStore('product', () => {
  const products = ref<Product[]>([]);
  const loading = ref(false);
  const error = ref<string | null>(null);

  async function fetchProducts(keyword?: string): Promise<void> {
    loading.value = true;
    error.value = null;
    try {
      const response = await productApi.getAll(keyword);
      products.value = response.data;
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Failed to load products';
      throw err;
    } finally {
      loading.value = false;
    }
  }

  async function createProduct(payload: ProductPayload): Promise<Product> {
    loading.value = true;
    error.value = null;
    try {
      const response = await productApi.create(payload);
      products.value.push(response.data);
      return response.data;
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Failed to create product';
      throw err;
    } finally {
      loading.value = false;
    }
  }

  async function updateProduct(id: number, payload: ProductPayload): Promise<Product> {
    loading.value = true;
    error.value = null;
    try {
      const response = await productApi.update(id, payload);
      const index = products.value.findIndex((item) => item.id === id);
      if (index !== -1) {
        products.value[index] = response.data;
      }
      return response.data;
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Failed to update product';
      throw err;
    } finally {
      loading.value = false;
    }
  }

  async function deleteProduct(id: number): Promise<void> {
    loading.value = true;
    error.value = null;
    try {
      await productApi.remove(id);
      products.value = products.value.filter((item) => item.id !== id);
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Failed to delete product';
      throw err;
    } finally {
      loading.value = false;
    }
  }

  return {
    products,
    loading,
    error,
    fetchProducts,
    createProduct,
    updateProduct,
    deleteProduct,
  };
});
