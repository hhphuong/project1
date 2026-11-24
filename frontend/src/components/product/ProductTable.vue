<script setup lang="ts">
import BaseButton from '@/components/common/BaseButton.vue';
import type { Product } from '@/types/product';

interface Props {
  products: Product[];
  loading?: boolean;
}

withDefaults(defineProps<Props>(), {
  loading: false,
});

const emit = defineEmits<{
  edit: [product: Product];
  delete: [product: Product];
}>();

function formatPrice(value: number): string {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(value);
}
</script>

<template>
  <div class="card table-wrapper">
    <div v-if="loading && products.length === 0" class="empty-state">
      Loading products...
    </div>

    <div v-else-if="products.length === 0" class="empty-state">
      No products found. Click "Add Product" to create one.
    </div>

    <table v-else class="data-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Description</th>
          <th>Price</th>
          <th>Quantity</th>
          <th>Status</th>
          <th class="actions-col">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="product in products" :key="product.id">
          <td>#{{ product.id }}</td>
          <td class="name-cell">{{ product.name }}</td>
          <td class="desc-cell">{{ product.description || '—' }}</td>
          <td>{{ formatPrice(product.price) }}</td>
          <td>{{ product.quantity }}</td>
          <td>
            <span :class="['badge', product.active ? 'badge-success' : 'badge-muted']">
              {{ product.active ? 'Active' : 'Inactive' }}
            </span>
          </td>
          <td class="actions-cell">
            <BaseButton variant="secondary" @click="emit('edit', product)">Edit</BaseButton>
            <BaseButton variant="danger" @click="emit('delete', product)">Delete</BaseButton>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>
.empty-state {
  text-align: center;
  padding: 36px 16px;
  color: var(--color-text-muted);
}

.name-cell {
  font-weight: 600;
}

.desc-cell {
  max-width: 280px;
  color: var(--color-text-muted);
}

.actions-col {
  text-align: right;
}

.actions-cell {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>
