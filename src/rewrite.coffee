{puts,inspect} = require("util")
esprima = require("esprima")
escodegen = require("escodegen")

source = """
function bubbleSort    (list) {
var items = list.slice(0), swapped =false,
        p,   q;
   for ( p= 1;p <   items.length; ++p) {
       for (q=0; q < items.length -    p; ++q) {
        if (items[q + 1  ] < items[q]) {
            swapped =true;
        let temp = items[q];
         items[q] = items[ q+1]; items[q+1] = temp;
            }
      }
        if (!swapped)
        break;
    }
       return items; alert("Finish");
}
  """

sourceRewrite = (code)->
  option =
    comment: true
    format:
      indent:
        style: "  "
      quotes: "double"

  syntax = esprima.parse(code,
    raw: true
    tokens: true
    range: true
    comment: true
  )
  syntax = escodegen.attachComments(syntax, syntax.comments, syntax.tokens)
  code = escodegen.generate(syntax, option)
  puts code

sourceRewrite(source)
