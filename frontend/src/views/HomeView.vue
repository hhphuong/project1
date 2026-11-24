<script setup lang="ts">
import { RouterLink } from 'vue-router';
</script>

<template>
  <section class="home-view">
    <div class="card hero-card">
      <h1>Java 21 + Vue 3 + MySQL Template</h1>
      <p class="subtitle">
        Dự án mẫu đã cấu hình sẵn kiến trúc phân tầng, Dependency chuẩn và module
        <strong>Product CRUD</strong> để cả team tham khảo và phát triển tính năng mới.
      </p>
      <RouterLink to="/products" class="cta-link">Open Product CRUD Sample &rarr;</RouterLink>
    </div>

    <div class="stack-grid">
      <div class="card">
        <h3>Backend (Java 21)</h3>
        <ul>
          <li>Spring Boot 3.3.5 + Maven</li>
          <li>Spring Data JPA + MySQL 8</li>
          <li>Validation + Global Exception Handler</li>
          <li>Swagger UI tại <code>/swagger-ui.html</code></li>
        </ul>
      </div>

      <div class="card">
        <h3>Frontend (Vue 3)</h3>
        <ul>
          <li>Vite + TypeScript + Composition API</li>
          <li>Pinia Store (<code>useProductStore</code>)</li>
          <li>Axios Client + Interceptor chuẩn hóa lỗi</li>
          <li>Vue Router + Lazy Loading Views</li>
        </ul>
      </div>

      <div class="card">
        <h3>Quy ước code</h3>
        <ul>
          <li>Tách biệt <code>backend/</code> và <code>frontend/</code></li>
          <li>Chuẩn response <code>ApiResponse&lt;T&gt;</code></li>
          <li>Hướng dẫn chi tiết trong <code>PROJECT_STRUCTURE.md</code></li>
        </ul>
      </div>
    </div>
  </section>
</template>

<style scoped>
.hero-card {
  margin-bottom: 20px;
}

.hero-card h1 {
  margin: 0 0 8px;
  font-size: 1.65rem;
}

.subtitle {
  margin: 0 0 18px;
  color: var(--color-text-muted);
}

.cta-link {
  display: inline-block;
  padding: 10px 18px;
  border-radius: var(--radius-sm);
  background-color: var(--color-primary);
  color: #ffffff;
  font-weight: 600;
}

.cta-link:hover {
  background-color: var(--color-primary-hover);
}

.stack-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 16px;
}

.stack-grid h3 {
  margin: 0 0 10px;
}

.stack-grid ul {
  margin: 0;
  padding-left: 18px;
  color: var(--color-text-muted);
}

.stack-grid li + li {
  margin-top: 6px;
}
</style>
