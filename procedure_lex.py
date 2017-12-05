import sys
import ply.lex as lex
import ast

# reserved words
reserved = (
    'CREATE', 'PROCEDURE', 'IN', 'AS BEGIN', 'INTEGER', 'SELECT', 'FROM', 'WHERE', 'LIKE',
    'OR', 'BETWEEN', 'GROUP BY', 'NULL', 'IF', 'THEN', 'END IF', 'WHILE', 'END'
)

tokens = reserved + (
    # variable-related tokens
    'ASSIGN', 'INTNUM', 'ID',

    # condition operators (<, <=, >, >=, ==, !=)
    'LT', 'LE', 'GT', 'GE', 'EQ', 'NE'

    # sql
    'SELECT_QUERY', 'INSERT_QUERY'
)

# ignored chars
t_ignore = ' \t\x0c'

def t_NEWLINE(t):
    r'\n+'
    t.lexer.lineno += t.value.count("\n")

t_ASSIGN = r':='
t_INTNUM = r'\d+'
t_ID = r'[a-zA-Z_][a-zA-Z0-9_]*'

t_LT = r'<'
t_GT = r'>'
t_LE = r'<='
t_GE = r'>='
t_EQ = r'=='
t_NE = r'!='

t_SELECT_QUERY = r'(?i)select (.*) from (.*)( where (.*))?'
t_INSERT_QUERY = r'(?i)insert into (.*) \([a-zA-Z_](,[a-zA-Z_])*\) values \(.*(,.*)*\)'



reserved_map = {}
for r in reserved:
    reserved_map[r.lower()] = r

def t_comment(t):
    r'--.*(\n|\Z)'
    t.lexer.lineno += t.value.count('\n')

def t_error(t):
    print("Illegal character %s" % repr(t.value[0]))
    t.lexer.skip(1)

lexer = lex.lex()
if __name__ == '__main__':
    with open('datas/input1.sql') as f:
        code = f.read()
    lexer.input(code)
    lex.runmain(lexer)
