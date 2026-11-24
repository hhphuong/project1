<script setup lang="ts">
interface Props {
  variant?: 'primary' | 'secondary' | 'danger';
  type?: 'button' | 'submit' | 'reset';
  loading?: boolean;
  disabled?: boolean;
}

withDefaults(defineProps<Props>(), {
  variant: 'primary',
  type: 'button',
  loading: false,
  disabled: false,
});
</script>

<template>
  <button
    :type="type"
    :disabled="disabled || loading"
    :class="['base-btn', `base-btn--${variant}`]"
  >
    <span v-if="loading">Processing...</span>
    <slot v-else />
  </button>
</template>

<style scoped>
.base-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 8px 16px;
  border-radius: var(--radius-sm);
  border: 1px solid transparent;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.15s ease, opacity 0.15s ease;
}

.base-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.base-btn--primary {
  background-color: var(--color-primary);
  color: #ffffff;
}

.base-btn--primary:hover:not(:disabled) {
  background-color: var(--color-primary-hover);
}

.base-btn--secondary {
  background-color: #ffffff;
  border-color: var(--color-border);
  color: var(--color-text);
}

.base-btn--secondary:hover:not(:disabled) {
  background-color: #f1f5f9;
}

.base-btn--danger {
  background-color: var(--color-danger);
  color: #ffffff;
}

.base-btn--danger:hover:not(:disabled) {
  background-color: var(--color-danger-hover);
}
</style>
