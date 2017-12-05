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

    # procedure blocks
    # 'PROCEDURE_BLOCK_LIST', 'PROCEDURE_BLOCK', 'BLOCK_DEPTH', 'PROCEDURE_BLOCK_BODY',
    # 'LOOP_BLOCK', 'LOOP_BLOCK_INFO',
    # 'STATEMENT_BLOCK', 'STATEMENT', 'STATEMENT_IO_TYPE', 'STATEMENT_BODY',
    # 'CONDITION_BLOCK', 'COND_INFO'
)

# ignored chars
t_ignore = ' \t\x0c'

def t_NEWLINE(t):
    r'\n+'
    t.lexer.lineno += t.value.count("\n")



t_ASSIGN = r':='
t_INTNUM = r'\d+'
t_ID = r'[a-zA-Z_][a-zA-Z0-9_]*'



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
