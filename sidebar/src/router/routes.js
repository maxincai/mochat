const routes = [
  {
    path: '/',
    name: 'index',
    component: () => import(/* webpackChunkName: "auth" */ 'views/index')
    // redirect: { name: 'codeAuth' }
  },
  {
    path: '/codeAuth',
    name: 'codeAuth',
    component: () => import(/* webpackChunkName: "auth" */ 'views/codeAuth')
  },
  {
    path: '/auth',
    name: 'auth',
    component: () => import(/* webpackChunkName: "auth" */ 'views/auth')
  },
  {
    path: '/contact',
    name: 'contact',
    component: () => import(/* webpackChunkName: "contact" */ 'views/contact'),
    meta: { initConfig: true }
  },
  {
    path: '/contact/remark',
    name: 'contactRemark',
    component: () => import(/* webpackChunkName: "contact" */ 'views/contact/remark'),
    meta: { initConfig: true }
  },
  {
    path: '/contact/settingTag',
    name: 'contactSettingTag',
    component: () => import(/* webpackChunkName: "contact" */ 'views/contact/settingTag'),
    meta: { initConfig: true }
  },
  {
    path: '/contact/editDetail',
    name: 'contactEditDetail',
    component: () => import(/* webpackChunkName: "contact" */ 'views/contact/editDetail'),
    meta: { initConfig: true }
  },
  {
    path: '/medium',
    name: 'medium',
    component: () => import(/* webpackChunkName: "medium" */ 'views/medium'),
    meta: { initConfig: true }
  },
  {
    path: '/404',
    name: '404',
    component: () => import(/* webpackChunkName: "404" */ 'views/error/404')
  },
  { path: '/:pathMatch(.*)', redirect: { name: '404' } },
  {
    path: '/contactSop',
    name: 'contactSop',
    component: () => import(/* webpackChunkName: "contact" */ 'views/contactSop/contactSop'),
    meta: { initConfig: true }
  },
  {
    path: '/contactBatchAdd',
    name: 'contactBatchAdd',
    component: () => import(/* webpackChunkName: "contactBatchAdd" */ 'views/contactBatchAdd/index'),
    meta: { initConfig: true }
  },
  // {
  //   path: '/contactSopIndex',
  //   name: 'contactSopIndex',
  //   component: () => import(/* webpackChunkName: "404" */ 'views/contactSop/contactSopIndex')
  // },
  {
    path: '/roomSop',
    name: 'roomSop',
    component: () => import(/* webpackChunkName: "room" */ 'views/roomSop/roomSop'),
    meta: { initConfig: true }
  },
  {
    path: '/room',
    name: 'room',
    component: () => import(/* webpackChunkName: "room" */ 'views/room/index'),
    meta: { initConfig: true }
  }
  // {
  //   path: '/pushRule',
  //   name: 'pushRule',
  //   component: () => import(/* webpackChunkName: "404" */ 'views/roomSop/pushRule')
  // },
  // {
  //   path: '/setCalendar',
  //   name: 'setCalendar',
  //   component: () => import(/* webpackChunkName: "404" */ 'views/roomSop/setCalendar')
  // }
]
export default routes
