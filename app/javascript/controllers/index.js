// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import SearchRecipesController from "./search_recipes_controller"
application.register("search-recipes", SearchRecipesController)

import ShowFiltersController from "./show_filters_controller"
application.register("show-filters", ShowFiltersController)

import TomSelectController from "./tom_select_controller"
application.register("tom-select", TomSelectController)
