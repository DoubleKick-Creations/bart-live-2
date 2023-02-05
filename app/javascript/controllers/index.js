// Import and register all your controllers from the importmap under controllers/*
import { application } from './application'
import Tooltip from'./tooltip_controller'
application.register('tooltip', Tooltip)