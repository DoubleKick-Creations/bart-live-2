// Import and register all your controllers from the importmap under controllers/*
import { application } from "./application"
import Reveal from 'stimulus-reveal-controller'
application.register('reveal', Reveal)