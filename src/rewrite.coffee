{puts,inspect} = require("util")
esprima = require("esprima")
escodegen = require("escodegen")
esmorph = require("esmorph")
_ = require("underscore")

# In this file, I'm using "statement" in a general sense and not in the
# particular javascript-syntax sense. A statement, seen as a variable name,
# simply means a unit of interest

source = """
// Life, Universe, and Everything
var answer = 6 * 7;
var foo = "bar";
console.log(answer); console.log(foo);

// parabolas
var shift = 0;
while (shift <= 200) {
  console.log(shift);
  shift += 14; // increment
}

try {
  var i = 1/0;
} catch(err) {
  console.log("uh oh");
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
  # puts "= #{object.type}"
  for key of object
    # puts "  #{key}"
    if object.hasOwnProperty(key)
      child = object[key]
      traverse child, visitor, [object].concat(path) if typeof child is "object" and child isnt null

collectStatements = (code, tree) ->
  statements = []
  traverse tree, (node, path) ->
    if isStatement(node.type)
      # puts inspect path, null, 10
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
    tokens: false
    range: false
    comment: false
  )
  # syntax = escodegen.attachComments(syntax, syntax.comments, syntax.tokens)

  statements = collectStatements code, syntax

  statements[0].node.interesting = "foo"

  addition = 
    type: 'ThrowStatement'
    argument:
      type: 'NewExpression'
      callee:
        type: 'Identifier'
        name: 'Error'
      arguments: [
        type: 'Literal'
        value: '__choc_pause'
        raw: '"__choc_pause"'
        ]

  puts inspect syntax, null, 100
  syntax.body.unshift(addition)

  code = escodegen.generate(syntax, option)
  puts "\n======="
  puts "Statements: #{statements.length}\n"
  puts code

# sourceRewrite(source)


collectStatements = (code, tree) ->
  statements = []
  traverse tree, (node, path) ->
    if isStatement(node.type)
      statements.push { node: node, path: path }
  statements

tracers = 
  postStatement: (traceName) ->
    (code) ->
      tree = esprima.parse(code, { range: true, loc: true })
      statementList = collectStatements(code, tree)

      fragments = []
      i = 0
      while i < statementList.length
        node = statementList[i].node
        nodeType = node.type
        line = node.loc.start.line
        range = node.range
        pos = node.range[1]

        # puts inspect node, null, 10 if nodeType == "TryStatement"

        if node.hasOwnProperty("body")
          pos = node.body.range[0] + 1
        else if node.hasOwnProperty("block")
          pos = node.block.range[0] + 1

        if typeof traceName is "function"
          signature = traceName.call(null,
            line: line
            range: range
          )
        else
          signature = traceName + "({ "
          signature += "lineNumber: " + line + ", "
          signature += "range: [" + range[0] + ", " + range[1] + "], "
          signature += "type: '" + nodeType + "' "
          signature += "});"

        signature = " " + signature + ""
        fragments.push
          index: pos
          text: signature

        i += 1

      fragments

modifiers = [ tracers.postStatement("__choc_trace") ]
morphed = esmorph.modify(source, modifiers)

puts morphed


