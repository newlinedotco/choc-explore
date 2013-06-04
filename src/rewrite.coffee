{puts,inspect} = require("util")
esprima = require("esprima")
escodegen = require("escodegen")
_ = require("underscore")

source = """
// Life, Universe, and Everything
var answer = 6 * 7;
var foo = "bar";
console.log(answer);
console.log(foo);
  """

isStatement = (thing) ->
  statements = ['BlockStatement', 'BreakStatement', 'ContinueStatement', 'DoWhileStatement',
  'DebuggerStatement', 'EmptyStatement', 'ExpressionStatement', 'ForStatement',
  'ForInStatement', 'IfStatement', 'LabeledStatement', 'ReturnStatement',
  'SwitchStatement', 'ThrowStatement', 'TryStatement', 'WhileStatement',
  'WithStatement']
  _.contains(statements, thing)

isExpression = (thing) ->
  expressions = ['AssignmentExpression', 'ArrayExpression', 'BinaryExpression',
  'CallExpression', 'ConditionalExpression', 'FunctionExpression',
  'LogicalExpression', 'MemberExpression', 'NewExpression', 'ObjectExpression',
  'SequenceExpression', 'ThisExpression', 'UnaryExpression', 'UpdateExpression']
  _.contains(expressions, thing)

# Executes visitor on the object and its children (recursively).
traverse = (object, visitor, path) ->
  key = undefined
  child = undefined
  path = []  if typeof path is "undefined"
  visitor.call null, object, path
  for key of object
    if object.hasOwnProperty(key)
      child = object[key]
      traverse child, visitor, [object].concat(path) if typeof child is "object" and child isnt null

collectUnits = (code, tree) ->
  units = []
  traverse tree, (node, path) ->
    if isStatement(node.type) || isExpression(node.type)
      puts node.type
      units.push { node: node }
  units

sourceRewrite = (code)->
  option =
    comment: true
    format:
      indent:
        style: "  "
      quotes: "double"

  syntax = esprima.parse(code,
    loc: true
    raw: true
    tokens: true
    range: false
    comment: true
  )
  # syntax = escodegen.attachComments(syntax, syntax.comments, syntax.tokens)
  # puts inspect syntax.body, null, 10
  collectUnits code, syntax

  code = escodegen.generate(syntax, option)
  puts code

sourceRewrite(source)
