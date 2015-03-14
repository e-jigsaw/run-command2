{$, View, TextEditorView} = require 'atom-space-pen-views'
{CommandRunner} = require './command-runner'
{CommandRunnerView} = require './command-runner-view'

{Disposable, CompositeDisposable} = require 'atom'

CWDView = require './cwd-view'
Utils = require './utils'

module.exports =
class RunCommandView extends View
  @content: ->
    @div class: 'run-command padded overlay from-top', =>
      @subview 'commandEntryView', new TextEditorView(mini: true, placeholderText: atom.project.getPaths()[0])


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
    atom.commands.add 'atom-workspace', 'run-command:cwd', =>
      @setWorkingDirectory()

    @disposables.add atom.commands.add @element,
      'core:confirm': =>
        @runCommand()
      'core:cancel': =>
        @hide()

    @commandEntryView.on 'focusout', =>
      @hide()

    @commandEntryView.on 'keydown', (e) =>
      if e.keyCode is 9
        e.preventDefault()
        console.log(e.keyCode)

  serialize: ->

  setWorkingDirectory: =>

    if not @cwd?
      @cwd ?= new CWDView()
    else
      @toggleCWD()

  toggleCWD: ->

    if @cwd.panel.isVisible()
      @cwd.panel.hide()
    else
      @cwd.panel.show()
      #@cwd.panel.addClass('overlay from-top')
      @cwd.setItems(atom.project.getPaths())
      @cwd.focusFilterEditor()

  runCommand: =>

    command = @commandEntryView.getText()
    cwd = @cwd?.cwd() || atom.project.getPaths()[0]


    unless Utils.stringIsBlank(command)
      @commandRunnerView.runCommand(command, cwd)
    @hide()

  reRunCommand: (e) =>
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
      cwd = @cwd?.cwd() || atom.project.getPaths()[0]
      @commandEntryView?.model.placeholderText = cwd
      @show()

  togglePanel: =>
    @commandRunnerView.togglePanel()

  show: =>
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel?.show()

    @storeFocusedElement()
    @commandEntryView.focus()

  hide: =>
    @panel?.hide()
    @commandEntryView.setText('')

  destroy: =>
    @hide()
