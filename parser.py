import ply.lex as lex
import ply.yacc as yacc

# list of token names
tokens = (
    # procedure declaration 관련 tokens
    'CREATE',
    'PROCEDURE',
    'PROCEDURE_NAME',
    'PARAMS',
    'AS_BEGIN',
    'END',

    # statements 관련 tokens
    'SQL',

    # variable 관련 tokens
    # array는 생략
    'DECLARE',
    'VAR_NAME',
    'VAR_TYPE',

    # For loop 관련
    'FOR',
    'FOR_INDEX',
    'IN',
    'RANGE',    # ex. 1..5
    'DO',
    'END_FOR',

    # Simple statement
    'SIMPLE_STATEMENT',

)

# regular expressions
t_CREATE = r'CREATE'
t_PROCEDURE = r'PROCEDURE'
t_PROCEDURE_NAME = r'.*'
t_PARAMS = r'\(\)'

def t_SQL(t):
    r''
    try:
        pass
    except ValueError:
        pass
    pass
    return t

reserved = {
    'IF': 'IF'
}
