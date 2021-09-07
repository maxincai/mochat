import { createRouter, createWebHistory } from 'vue-router'
// import store from '@/store'
import routes from './routes'
import { Toast } from 'vant'
// eslint-disable-next-line no-unused-vars
import { checkLogin, navShow, initConfig } from '@/utils'

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

router.beforeEach(async (to, from, next) => {
  try {
    if (from.path !== '/codeAuth' || from.path !== '/auth') {
      await checkLogin(to, from, next)
    }

    if (to.matched.some(record => record.meta.initConfig)) {
      await initConfig(to, from, next)
    }

    next()
  } catch (e) {
    Toast({ position: 'top', message: '获取用户信息失败' })
    next({ path: '/' })
    console.log(e)
  }
})

router.afterEach(async (to, from) => {

  navShow(to)
})
export default router
