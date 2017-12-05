import procedure_lex
import ply.yacc as yacc

tokens = procedure_lex.tokens

def p_procedure_block_list(t):
    '''procedure_block_list : procedure_block
                            | procedure_block_list procedure_block'''
    pass

def p_procedure_block(t):
    'procedure_block : procedure_block_depth procedure_block_body'
    pass

def p_procedure_block_depth(t):
    'procedure_block_depth : INTNUM'
    pass

def p_procedure_block_body(t):
    '''procedure_block_body : loop_block
                            | statement_block
                            | condition_block'''
    pass

def p_loop_block(t):
    'loop_block : loop_block_info procedure_block_list'
    pass

def p_loop_block_info(t):
    'loop_block_info : loop_type loop_block_index loop_block_index_range'
    pass

def p_loop_type(t):
    '''loop_type : FOR
                 | WHILE'''
    pass

def p_loop_block_index(t):
    'loop_block_index : ID'
    pass

def p_loop_block_index_range(t):
    'loop_block_index_range : INTNUM INTNUM'
    pass

def p_statement_block(t):
    'statement_block : statement_list'
    pass

def p_statement_list(t):
    '''statement_list : statement
                      | statement_list statement'''
    pass

def p_statement(t):
    '''statement : SELECT_QUERY
                 | INSERT_QUERY
                 | assign_statement'''
    pass

def p_assign_statement(t):
    '''assign_statement : ID ASSIGN ID
                        | ID ASSIGN SELECT_QUERY'''
    pass

def p_condition_block(t):
    'condition_block : condition_info procedure_block_list'
    pass

def p_condition_info(t):
    '''condition_info : operand LT operand
                      | operand GT operand
                      | operand LE operand
                      | operand GE operand
                      | operand EQ operand
                      | operand NE operand'''
    pass

def p_operand(t):
    '''operand : ID
               | INTNUM'''
    pass

# empty
def p_empty(t):
    'empty : '
    pass

yacc.yacc()