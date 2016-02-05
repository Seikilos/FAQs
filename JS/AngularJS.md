# Things about AngularJS




* Use anonymous function (closures) to create modules and controllers to prevent global scope cluttering when storing single controllers in variables
```javascript
(function(){
...
})();
```

* Minifcation may destroy services and scopes passed into controllers, either $inject afterwards or provide a string array of services in the order of appearance in the controller declaration.
```javascript
(function(){
myApp.controller('MyCtrl', ['$scope', '$http', function($scope, $http) {...}]);
})();
```

## Questions

* Using Route, how should state be transported? Typing text in a textbox should spawn routes?

I have multiple controllers reached via routing and views, how can I keep data in a controller?
* First solution: Encoding the data in the route may be viable
* Second solution: Use the $rootScope, be aware of pollution as this will be a global pool
* Create a service that returns an object with persistent properties and pass it into the controller. See http://stackoverflow.com/questions/12940974/maintain-model-of-scope-when-changing-between-views-in-angularjs

## Scopes

https://docs.angularjs.org/api/ng/type/$rootScope.Scope

* {{ }} Braces create a dynamic binding (with updates)
* Angular expressions are evaluated in context of current model scope, not global window
* Boostrapping creates root scope, which is the context of the model
* Each controller creates a scope which is a child of the parent scope (root scope or other nested scopes)
* $scope prototype is a descendant from root scope passed into a controller and is the scope for all tags nested deeper than the corresponding ng-controller declaration

## Built-in directives

* ng-repeat="o in objects" similar to foreach (https://docs.angularjs.org/api/ng/directive/ngRepeat)
* ng-controller="FooCtrl" instantiates a controller in given html tag
* ng-app may specify a module which is then loaded and from which controllers can be reached (https://docs.angularjs.org/api/ng/type/angular.Module)
* ng-bind and ng-bind-template directives can be used to prevent rending {{ }} curly braces before ng is bootstrapped
* ng-src creates proper urls in images,etc. src would not work as the {{}} statement is treated literally
* ng-view includes a view template for current route (https://docs.angularjs.org/api/ngRoute/directive/ngView)
* ng-class: Applies given class if condition is met


## Filters

https://docs.angularjs.org/api/ng/filter/filter

* Can be applied to e.g. ng-repeat to filter based on condition
* filter: filters content
* orderBy: provides sorting (creates a copy of input array, sorts and returns it)


## Services

https://docs.angularjs.org/guide/services

* Can be injected into controllers to provide DI, e.g $http, $route
* Built-in services are prefixed with $
* ngResource better service than $http, allows better REST (https://docs.angularjs.org/api/ngResource/service/$resource)

## Modules

### Routing
* separate dependency ngRoute

### Animation

* ngAnimate, can use jQuery
* Animation resources: https://docs.angularjs.org/guide/animations
* Ensure jQuery is loaded before AngularJS
* Hint: Animations are no longer not executed on page load (structural animations on boostrap) and either require hacking or paging in information
