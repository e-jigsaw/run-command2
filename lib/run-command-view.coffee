{$, View, TextEditorView} = require 'atom-space-pen-views'
{CommandRunner} = require './command-runner'
{CommandRunnerView} = require './command-runner-view'

{Disposable, CompositeDisposable} = require 'atom'

CWDView = require './cwd-view'
CommandEntry = require './command-entry'
Utils = require './utils'

module.exports =
class RunCommandView extends View

  @content: ->
    @div class: 'inset-panel panel-top run-command'

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

  serialize: ->

  setWorkingDirectory: =>

    if not @cwd?
      @cwd ?= new CWDView()
    else
      @toggleCWD()

  toggle: =>

    if not @entry?
      @entry ?= new CommandEntry(@)
    else
      if @entry?.panel.isVisible()
        @entry.panel.hide()
      else
        @entry.panel.show()
        @entry.focusFilterEditor()

  toggleCWD: ->

    if @cwd.panel.isVisible()
      @cwd.panel.hide()
    else
      @cwd.panel.show()
      @cwd.filterEditorView.setText(@cwd.cwd())
      @cwd.setItems(atom.project.getPaths())

      @cwd.focusFilterEditor()

  runCommand: =>
    command = @entry.filterEditorView.getText()
    cwd = @cwd?.cwd() || atom.project.getPaths()[0]

    unless Utils.stringIsBlank(command)
      @commandRunnerView.runCommand(command, cwd)

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

  togglePanel: =>
    @commandRunnerView.togglePanel()

  show: =>
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel?.show()

    @storeFocusedElement()
    @entry.focusFilterEditor()

  hide: =>
    @entry?.hide()

  destroy: =>
    @hide()
