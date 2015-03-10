{$, View, TextEditorView} = require 'atom-space-pen-views'
{CommandRunner} = require './command-runner'
{CommandRunnerView} = require './command-runner-view'

{Disposable, CompositeDisposable} = require 'atom'


Utils = require './utils'

module.exports =
class RunCommandView extends View
  @content: ->
    @div class: 'run-command padded overlay from-top', =>
      @subview 'commandEntryView', new TextEditorView(mini: true, placeholderText: 'Command...')


  initialize: (commandRunnerView)->
    @disposables = new CompositeDisposable

    @commandRunnerView = commandRunnerView

    atom.commands.add 'atom-workspace', 'run-command:run', =>
      @toggle()
    atom.commands.add 'atom-workspace', 'run-command:re-run-last-command', =>
      @reRunCommand()
    atom.commands.add 'atom-workspace', 'run-command:toggle-panel', =>
      @togglePanel()
    atom.commands.add 'atom-workspace', 'run-command:kill-last-command', =>
      @killLastCommand()

    @disposables.add atom.commands.add @element,
      'core:confirm': =>
        @runCommand()
      'core:cancel': =>
        @hide()

    @commandEntryView.on 'focusout', =>
      @hide()

    @commandEntryView.on

  serialize: ->

  runCommand: =>
    command = @commandEntryView.getText()

    unless Utils.stringIsBlank(command)
      @commandRunnerView.runCommand(command)
    @hide()

  reRunCommand: (e)=>
    @commandRunnerView.reRunCommand(e)

  killLastCommand: =>
    @commandRunnerView.killCommand()

  storeFocusedElement: =>
    @previouslyFocused = $(':focus')

  restoreFocusedElement: =>
    if @previouslyFocused?
      @previouslyFocused.focus()
    else
      atom.workspace.focus()

  toggle: =>
    if @panel?.isVisible()
      @hide()
    else
      @show()

  togglePanel: =>
    @commandRunnerView.togglePanel()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @storeFocusedElement()
    @commandEntryView.focus()

  hide: ->
    @panel?.hide()
    @commandEntryView.setText('')
    @panel.destroy

  destroy: =>
    @hide()
