<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router';
import { useNotification } from '@/composables/useNotification';

const { notifications, dismiss } = useNotification();
</script>

<template>
  <div class="app-shell">
    <header class="app-header">
      <div class="container header-inner">
        <RouterLink to="/" class="brand">Project Template</RouterLink>
        <nav class="nav-links">
          <RouterLink to="/" class="nav-link">Home</RouterLink>
          <RouterLink to="/products" class="nav-link">Products</RouterLink>
        </nav>
      </div>
    </header>

    <main class="container app-main">
      <RouterView />
    </main>

    <div v-if="notifications.length > 0" class="toast-container">
      <div
        v-for="item in notifications"
        :key="item.id"
        :class="['toast', `toast--${item.type}`]"
        @click="dismiss(item.id)"
      >
        {{ item.message }}
      </div>
    </div>
  </div>
</template>

<style scoped>
.app-header {
  background-color: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
}

.header-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 60px;
}

.brand {
  font-weight: 700;
  font-size: 1.1rem;
  color: var(--color-primary);
}

.nav-links {
  display: flex;
  gap: 16px;
}

.nav-link {
  font-weight: 500;
  color: var(--color-text-muted);
  padding: 6px 10px;
  border-radius: var(--radius-sm);
}

.nav-link.router-link-active {
  color: var(--color-primary);
  background-color: #eff6ff;
}

.app-main {
  padding-top: 28px;
  padding-bottom: 48px;
}

.toast-container {
  position: fixed;
  right: 20px;
  bottom: 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  z-index: 1000;
}

.toast {
  padding: 12px 16px;
  border-radius: var(--radius-sm);
  box-shadow: var(--shadow-md);
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
}

.toast--success {
  background-color: var(--color-success-bg);
  color: var(--color-success);
  border: 1px solid #bbf7d0;
}

.toast--error {
  background-color: var(--color-danger-bg);
  color: var(--color-danger);
  border: 1px solid #fecaca;
}
</style>
