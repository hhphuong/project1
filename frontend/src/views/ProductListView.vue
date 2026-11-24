<script setup lang="ts">
import { onMounted, ref } from 'vue';
import BaseButton from '@/components/common/BaseButton.vue';
import ProductForm from '@/components/product/ProductForm.vue';
import ProductTable from '@/components/product/ProductTable.vue';
import { useNotification } from '@/composables/useNotification';
import { useProductStore } from '@/stores/productStore';
import type { Product, ProductPayload } from '@/types/product';

const productStore = useProductStore();
const { notifySuccess, notifyError } = useNotification();

const keyword = ref('');
const showForm = ref(false);
const editingProduct = ref<Product | null>(null);

async function loadProducts(): Promise<void> {
  try {
    await productStore.fetchProducts(keyword.value);
  } catch (err) {
    notifyError(err instanceof Error ? err.message : 'Unable to fetch products');
  }
}

function openCreateForm(): void {
  editingProduct.value = null;
  showForm.value = true;
}

function openEditForm(product: Product): void {
  editingProduct.value = product;
  showForm.value = true;
}

function closeForm(): void {
  editingProduct.value = null;
  showForm.value = false;
}

async function handleSubmit(payload: ProductPayload): Promise<void> {
  try {
    if (editingProduct.value) {
      await productStore.updateProduct(editingProduct.value.id, payload);
      notifySuccess('Product updated successfully');
    } else {
      await productStore.createProduct(payload);
      notifySuccess('Product created successfully');
    }
    closeForm();
  } catch (err) {
    notifyError(err instanceof Error ? err.message : 'Operation failed');
  }
}

async function handleDelete(product: Product): Promise<void> {
  if (!window.confirm(`Delete product "${product.name}"?`)) {
    return;
  }

  try {
    await productStore.deleteProduct(product.id);
    notifySuccess('Product deleted successfully');
  } catch (err) {
    notifyError(err instanceof Error ? err.message : 'Failed to delete product');
  }
}

onMounted(() => {
  loadProducts();
});
</script>

<template>
  <section>
    <div class="page-header">
      <div>
        <h1 class="page-title">Product Management (Sample CRUD)</h1>
        <p class="page-desc">
          Connected to Spring Boot API <code>/api/v1/products</code>
        </p>
      </div>
      <BaseButton v-if="!showForm" @click="openCreateForm">+ Add Product</BaseButton>
    </div>

    <ProductForm
      v-if="showForm"
      :initial-data="editingProduct"
      :submitting="productStore.loading"
      @submit="handleSubmit"
      @cancel="closeForm"
    />

    <form class="search-bar" @submit.prevent="loadProducts">
      <input
        v-model="keyword"
        class="form-input"
        type="search"
        placeholder="Search products by name..."
      />
      <BaseButton type="submit" variant="secondary" :loading="productStore.loading">
        Search
      </BaseButton>
    </form>

    <ProductTable
      :products="productStore.products"
      :loading="productStore.loading"
      @edit="openEditForm"
      @delete="handleDelete"
    />
  </section>
</template>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 18px;
}

.page-title {
  margin: 0;
  font-size: 1.5rem;
}

.page-desc {
  margin: 4px 0 0;
  color: var(--color-text-muted);
  font-size: 0.9rem;
}

.search-bar {
  display: flex;
  gap: 10px;
  margin-bottom: 16px;
}
</style>
