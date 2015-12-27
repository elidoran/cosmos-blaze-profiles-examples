# none of these have a Template instance.
# They'll be added to an instance via Template.someName.profiles()
Template.profiles
  AutoSelectInput:
    events:
      'click input': (event) -> $(event.target).select()

  RealTimeInput:
    events:
      'keyup input': (event) -> $(event.target).change()

  CancelableInput:
    events:
      'keydown input': (event, template) ->
        if event.keyCode is 27
          value = template.valueVar.get()
          $(event.target).val(value).change().blur()

  FormField:
    helpers:
      value: -> Template.instance()?.$getValue?()

    events:
      'change input': (event, template) ->
        template.$setValue $(event.target).val()

  FieldStorage:
    functions:
      $getValue: ->
        @$collection().findOne(@$selector())?[@$fieldName()]

      $setValue: (value) ->
        modifier = $set: {}
        modifier.$set[@$fieldName()] = value
        @$collection().upsert @$selector(), modifier

  PersistentInput:
    onCreated:
      valueVar: -> @valueVar = new ReactiveVar

    helpers:
      value: ->
        Template.instance().valueVar.get() ? Template.instance().$getValue()

    events:
      'focus input': (e, t) -> t.valueVar.set t.$getValue()

      'blur input' : (e, template) -> template.valueVar.set null

# add the profiles to our template
Template.ExtremeInputComponent.profiles [
  'AutoSelectInput' # selects text when input is clicked
  'RealTimeInput'   # triggers input changed on keyup
  'CancelableInput' # Escape keypress restores original value
  'FormField'       # 'change input' event, but, expects an implementation of get/set
  'PersistentInput' # stores the original value in a reactive var (overrides value helper)
  'FieldStorage'    # implmements FormField's get/set stuff
]

# configure template specific functions used by the FieldStorage profile
Template.ExtremeInputComponent.functions
  $collection: -> Values
  $fieldName : -> 'value'
  $selector  : -> Template.currentData()?.id
