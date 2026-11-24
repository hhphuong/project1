<script setup lang="ts">
import { reactive, watch } from 'vue';
import BaseButton from '@/components/common/BaseButton.vue';
import type { Product, ProductPayload } from '@/types/product';

interface Props {
  initialData?: Product | null;
  submitting?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  initialData: null,
  submitting: false,
});

const emit = defineEmits<{
  submit: [payload: ProductPayload];
  cancel: [];
}>();

const form = reactive<ProductPayload>({
  name: '',
  description: '',
  price: 0,
  quantity: 0,
  active: true,
});

const errors = reactive<Partial<Record<keyof ProductPayload, string>>>({});

watch(
  () => props.initialData,
  (product) => {
    if (product) {
      form.name = product.name;
      form.description = product.description ?? '';
      form.price = Number(product.price);
      form.quantity = product.quantity;
      form.active = product.active;
    } else {
      form.name = '';
      form.description = '';
      form.price = 0;
      form.quantity = 0;
      form.active = true;
    }
    errors.name = undefined;
    errors.price = undefined;
    errors.quantity = undefined;
  },
  { immediate: true },
);

function validate(): boolean {
  errors.name = !form.name.trim() ? 'Product name is required' : undefined;
  errors.price = form.price <= 0 ? 'Price must be greater than 0' : undefined;
  errors.quantity = form.quantity < 0 ? 'Quantity must be 0 or greater' : undefined;

  return !errors.name && !errors.price && !errors.quantity;
}

function handleSubmit(): void {
  if (!validate()) {
    return;
  }

  emit('submit', {
    name: form.name.trim(),
    description: form.description.trim(),
    price: Number(form.price),
    quantity: Number(form.quantity),
    active: form.active,
  });
}
</script>

<template>
  <form class="card product-form" @submit.prevent="handleSubmit">
    <h3 class="form-title">
      {{ initialData ? `Edit Product #${initialData.id}` : 'Create New Product' }}
    </h3>

    <div class="form-group">
      <label class="form-label" for="product-name">Name *</label>
      <input
        id="product-name"
        v-model="form.name"
        class="form-input"
        type="text"
        placeholder="e.g. Mechanical Keyboard K8"
      />
      <span v-if="errors.name" class="form-error">{{ errors.name }}</span>
    </div>

    <div class="form-group">
      <label class="form-label" for="product-description">Description</label>
      <textarea
        id="product-description"
        v-model="form.description"
        class="form-textarea"
        rows="3"
        placeholder="Short product description..."
      />
    </div>

    <div class="form-row">
      <div class="form-group">
        <label class="form-label" for="product-price">Price (VND) *</label>
        <input
          id="product-price"
          v-model.number="form.price"
          class="form-input"
          type="number"
          min="1"
          step="1000"
        />
        <span v-if="errors.price" class="form-error">{{ errors.price }}</span>
      </div>

      <div class="form-group">
        <label class="form-label" for="product-quantity">Quantity *</label>
        <input
          id="product-quantity"
          v-model.number="form.quantity"
          class="form-input"
          type="number"
          min="0"
        />
        <span v-if="errors.quantity" class="form-error">{{ errors.quantity }}</span>
      </div>
    </div>

    <label class="checkbox-row">
      <input v-model="form.active" type="checkbox" />
      <span>Active (available for sale)</span>
    </label>

    <div class="form-actions">
      <BaseButton variant="secondary" @click="emit('cancel')">Cancel</BaseButton>
      <BaseButton type="submit" :loading="submitting">
        {{ initialData ? 'Update Product' : 'Create Product' }}
      </BaseButton>
    </div>
  </form>
</template>

<style scoped>
.product-form {
  margin-bottom: 20px;
}

.form-title {
  margin: 0 0 16px;
  font-size: 1.1rem;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 14px;
}

.checkbox-row {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
  font-size: 0.9rem;
  cursor: pointer;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>
