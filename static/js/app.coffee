require('./lib/jquery.js')
require('./lib/jquery-ui.js')
require('./lib/date.js')
require('./lib/fullcalendar.js')
_ = require('./lib/underscore.js')

require('./lib/angular.js')
require('./lib/angular-resource.js')

require('./lib/bootstrap/bootstrap-transition.js')
require('./lib/bootstrap/bootstrap-modal.js')

angular.module('kolosejApp', ['ngResource'])

.factory('Movies', ['$resource', ($resource) ->
  $resource('/movies/:slug')
])

.controller('MoviesCtrl', ['$scope', '$cacheFactory', 'Movies', ($scope, $cacheFactory, Movies) ->
  $scope.events = []
  $scope.cities = {}
  $scope.city = 'Ljubljana'
  $scope.center = 'Kolosej Ljubljana'
  $scope.movie = null

  Movies.get (res) ->
    $scope.movies = res.movies
    $scope.events = []
    
    $scope.cities = {}

    now = Date.now()

    _.each $scope.movies, (movie) ->
      _.each movie.shows, (show) ->
        $scope.cities[show.city] ?= {}
        $scope.cities[show.city][show.center] = yes

        start = Date.parse("#{show.date} #{show.time}")
        end = start.clone().add(minutes: 10 + movie.duration)

        if start > now
          $scope.events.push
            id: show.id
            title: movie.title,
            start: start
            end: end
            allDay: no,
            movie: movie
            city: show.city
            center: show.center

  $scope.eventClick = (event) ->
    $scope.movie = event.movie

    slug = $scope.movie.url.split('/').slice(-2, -1)[0]

    $scope.movieExtra = Movies.get slug: slug

    $scope.showMovieDetails()

  $scope.$watch '[cities, city] | json', (city) ->
    if Object.keys($scope.cities).length
      if not $scope.cities[$scope.city][$scope.center]?
        $scope.center = Object.keys($scope.cities[$scope.city])[0]

  $scope.filteredEvents = []

  $scope.$watch '[events, city, center] | json', ->
    $scope.filteredEvents = _.filter $scope.events, (e) ->
      e.city == $scope.city and e.center == $scope.center
])

.directive('fullcalendar', ->
  restrict: 'E'
  scope:
    events: '='
    eventClick: '&'
  template: '<div></div>'
  replace: yes
  controller: ['$scope', '$element', ($scope, $element) ->
    $element.fullCalendar
      header:
        left: 'prev,next today'
        center: ''
        right: ''
      firstDay: 1
      defaultView: 'agendaDay'
      allDaySlot: no
      minTime: Date.now().getHours()
      firstHour: Date.now().getHours()

      events: (from, to, cb) ->
        if $scope.events?
          cb($scope.events)

      eventClick: (calEvent, jsEvent, view) ->
        $scope.$apply ->
          $scope.eventClick(event: calEvent)

    $scope.$watch 'events', (events) ->
      if events?
        $element.fullCalendar('refetchEvents')
        
  ]
)

.directive('bootModal', ->
  (scope, elm, attr) ->
    attr.$observe 'show', (show) ->
      scope[show] = ->
        elm.modal('show')
)

.filter('duration', ->
  (time) ->
    h = (time / 60) >> 0
    m = time % 60
    "#{h} h #{m} min"
)
