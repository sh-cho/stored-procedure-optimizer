import procedure_lex
import ply.yacc as yacc

tokens = procedure_lex.tokens

def p_procedure_block_list(t):
    'procedure_block_list : procedure_block_list procedure_block'
    pass

def p_procedure_block(t):
    'procedure_block : procedure_block_depth procedure_block_body'
    pass

def p_procedure_block_depth(t):
    'procedure_block_depth : INTVAL'
    pass

def p_procedure_block_body(t):
    ''
    pass

def p_empty(t):
    'empty: '
    pass