import { createRouter, createWebHistory } from 'vue-router'
import { useWeb3Store } from '@/stores/web3Store'

import HomePage from '@/pages/HomePage.vue'
import ProfilePage from '@/pages/ProfilePage.vue'
import DashboardPage from '@/pages/DashboardPage.vue'

const routes = [
  { 
    path: '/', 
    component: HomePage,
    meta: { requiresAuth: false }
  },
  { 
    path: '/profile', 
    component: ProfilePage,
    meta: { requiresAuth: true }
  },
  { 
    path: '/dashboard', 
    component: DashboardPage,
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const web3Store = useWeb3Store()
  
  if (to.meta.requiresAuth && !web3Store.isConnected) {
    next('/')
  } else {
    next()
  }
})

export default router
