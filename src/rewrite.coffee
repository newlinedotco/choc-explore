{puts,inspect} = require("util")
esprima = require("esprima")
escodegen = require("escodegen")
_ = require("underscore")

# In this file, I'm using "statement" in a general sense and not in the
# particular javascript-syntax sense. A statement, seen as a variable name,
# simply means a unit of interest

source = """
// Life, Universe, and Everything
var answer = 6 * 7;
var foo = "bar";
console.log(answer);
console.log(foo);

// parabolas
var shift = 0;
while (shift <= 200) {
  console.log(shift);
  shift += 14; // increment
}
  """

isStatement = (thing) ->

  # 'BlockStatement',

  statements = [
    'BreakStatement', 'ContinueStatement', 'DoWhileStatement',
    'DebuggerStatement', 'EmptyStatement', 'ExpressionStatement', 'ForStatement',
    'ForInStatement', 'IfStatement', 'LabeledStatement', 'ReturnStatement',
    'SwitchStatement', 'ThrowStatement', 'TryStatement', 'WhileStatement',
    'WithStatement',

    'VariableDeclaration'
  ]
  _.contains(statements, thing)

isExpression = (thing) ->
  expressions = [
    'AssignmentExpression', 'ArrayExpression', 'BinaryExpression',
    'CallExpression', 'ConditionalExpression', 'FunctionExpression',
    'LogicalExpression', 'MemberExpression', 'NewExpression', 'ObjectExpression',
    'SequenceExpression', 'ThisExpression', 'UnaryExpression', 'UpdateExpression'
  ]
  _.contains(expressions, thing)

isStatementish = (thing) ->
  interesting = [
    'VariableDeclaration', 'ExpressionStatement', 'WhileStatement'
  ]
  _.contains(interesting, thing)

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

collectStatements = (code, tree) ->
  statements = []
  traverse tree, (node, path) ->
    if isStatement(node.type)
      # puts node.type
      # puts inspect node, null, 10
      statements.push { node: node, path: path }
  statements

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
    range: true
    comment: true
  )
  syntax = escodegen.attachComments(syntax, syntax.comments, syntax.tokens)

  statements = collectStatements code, syntax
  statements[0].node.interesting = "foo"

  puts inspect syntax, null, 5

  code = escodegen.generate(syntax, option)
  puts "\n======="
  puts "Statements: #{statements.length}\n"
  puts code

sourceRewrite(source)
