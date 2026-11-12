import ast,json,re,sys
root=sys.argv[1]
src=open(root+'/events.gd',encoding='utf8').read()
def const(name):
    m=re.search(r'^const '+name+r' := (.*?)^(?=const |#|\Z)',src,re.S|re.M)
    return ast.literal_eval(m.group(1).strip())
D={'EVENTS':const('EVENTS'),'OPPONENTS':const('OPPONENTS'),'WIN':const('WIN_LINES'),'DRAW':const('DRAW_LINES'),'LOSS':const('LOSS_LINES'),
   'SACK_LOW':const('SACK_LOW'),'SACK_HIGH':const('SACK_HIGH'),'RANKS':const('RANKS')}
t=open(root+'/web/template.html',encoding='utf8').read().replace('__DATA__',json.dumps(D,ensure_ascii=False).replace('</','<\\/'))
open(root+'/index.html','w',encoding='utf8').write(t)
print(len(D['EVENTS']),'events',len(t),'bytes')
