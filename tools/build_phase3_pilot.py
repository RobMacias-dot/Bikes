"""Rebuild the separate editorial development pilot; never edits master 0.1.0."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'mobile/assets/knowledge/pilot'
OUT.mkdir(exist_ok=True)
def write(name, data):
    (OUT / (name + '.json')).write_text(json.dumps(data, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')

sources = [
 ('chain', 'iFixit', 'How to Fix a Slipped Bicycle Chain', 'https://www.ifixit.com/Guide/How+to+Fix+a+Slipped+Bicycle+Chain/37682', 'Steps 2–3 and conclusion only; excludes shortening and joining'),
 ('tube', 'Park Tool', 'Tire and Tube Removal and Installation', 'https://www.parktool.com/en-us/blog/repair-help/tire-and-tube-removal-and-installation', 'Sections 2–9'),
 ('wheel', 'Park Tool', 'Wheel Removal and Installation', 'https://www.parktool.com/en-us/blog/repair-help/wheel-removal-and-installation', 'Removal and installation'),
 ('fit', 'Park Tool', 'Tire, Wheel and Inner Tube Fit Standards', 'https://www.parktool.com/en-us/blog/repair-help/tire-wheel-and-inner-tube-fit-standards', 'Tires and inner tubes'),
 ('pressure', 'Schwalbe', 'Inflation Pressure', 'https://www.schwalbe.com/en/technology-faq/tire-pressure/', 'What is the right air pressure for my tire?'),
 ('rim', 'Schwalbe', 'Tire Dimensions', 'https://www.schwalbetires.com/technology-faq/tire-dimensions/', 'Which tire fits which rim? Manufacturer pressure and tire-type instructions'),
 ('index', 'Park Tool', 'Rear Derailleur Adjustment', 'https://www.parktool.com/en-us/blog/repair-help/rear-derailleur-adjustment', 'Preliminary info and Indexing Adjustment'),
 ('disc', 'Park Tool', 'Hydraulic Disc Brake Alignment', 'https://www.parktool.com/en-us/blog/repair-help/hydraulic-disc-brake-alignment', 'Diagnosis and Alignment Procedure'),
]
sources = [dict(id=i,publisher=p,document=d,url=u,section=s,revision='Página web sin revisión declarada; consulta 2026-09-07',reviewedAt='2026-09-07') for i,p,d,u,s in sources]
def choice(i,label,n,**kw): return dict(id=i,label=label,next=n,**kw)
def check(i,text,next, no='stop'):
    return dict(id=i,kind='check',text=text,choices=[choice('yes','Sí',next),choice('no','No / no puedo comprobarlo',no)])
def step(i,text,next): return dict(id=i,kind='step',text=text,next=next)
flags = {'structural_damage':'Daño estructural visible', 'braking_loss':'Pérdida efectiva de frenado', 'steering_damage':'Dirección dañada', 'critical_part_broken':'Pieza crítica rota'}
def procedure(key,title,problem,category,terms,known,scope,actions,tools,consumables,minutes,final):
    nodes=[dict(id='safety',kind='safetyCheck',text='Antes de intervenir, detente y revisa la bicicleta. Si no puedes evaluar su seguridad, solicita ayuda.',choices=[*[choice(f,l,'hard_stop',hardStop=f) for f,l in flags.items()],choice('clear','No observo estas señales','identify')]),
        dict(id='identify',kind='identify',profileKey=key,text='Identifica el sistema. El dato del perfil no sustituye revisar esta bicicleta.',choices=[choice('known',known,'scope',profileValue='known'),choice('other','Otro sistema','stop',profileValue='other'),choice('unknown','No sé','stop',profileValue='unknown')]),
        check('scope',scope,'context'),
        dict(id='context',kind='contextBranch',text='Preparar el lugar de trabajo',routes=dict(route='route',workshop='workshop')),
        check('route','¿Estás fuera del tránsito, en suelo estable, con luz y todos los recursos indicados?','action0'),
        check('workshop','¿Tienes espacio estable, buena luz y todos los recursos indicados en casa o taller?','action0'),
        *actions,
        check('worked','¿Funcionó? ¿Desapareció el síntoma en la comprobación anterior?','final'),
        dict(id='final',kind='finalCheck',text=final,choices=[choice('pass','Sí, pasó toda la prueba','complete',verdict='pass'),choice('fail','No / no pude probar','stop',verdict='fail')]),
        dict(id='complete',kind='outcome',text='Se resolvió el síntoma dentro del alcance de este piloto y pasó la prueba final. Si reaparece, detente y solicita diagnóstico.',result='complete',restrictions=[]),
        dict(id='stop',kind='outcome',text='Este piloto no puede confirmar una reparación segura. No continúes circulando; solicita revisión o traslado. No fuerces ajustes ni adivines especificaciones.',result='stop',restrictions=[]),
        dict(id='hard_stop',kind='outcome',text='Se registró una señal crítica. No circules ni continúes este procedimiento. Solicita traslado y evaluación profesional; esta sesión permanece bloqueada.',result='stop',restrictions=[])]
    return dict(id='dev.pilot.'+key,title='[PRUEBA] '+title,problem=problem,category=category,terms=terms,bikeTypes=['MTB','Ruta','Gravel','Urbana'],contexts=['route','workshop'],tools=[],toolIds=tools,consumableIds=consumables,difficulty='basic' if key=='chain' else 'intermediate',risk='moderate',estimatedMinutes=dict(min=minutes[0],max=minutes[1]),safetyFocus=list(flags),sourceIds=[key]+(['wheel','fit','pressure','rim'] if key=='tube' else []),specificationIds=[],entry='safety',nodes=nodes)

procedures=[
 procedure('chain','Cadena salida del plato','La cadena cayó del plato; sigue entera y libre.','drivetrain',['cadena salida','cadena caída','pedales giran sin avanzar'], 'Transmisión sin motor, con desviador trasero y plato convencional',
 '¿Confirmas ese sistema, cadena entera, libre y sin deformaciones, fuera del plato pero aún en los piñones? Este piloto excluye cadena atrapada, salidas repetidas, guías y platos de dientes alternos.',
 [step('action0','Con la bicicleta estable y las bielas inmóviles, empuja suavemente la jaula del desviador hacia delante para obtener holgura. Si se resiste, detente; no fuerces.','free'),
 check('free','¿Hay holgura suficiente sin forzar?','action1'),
 step('action1','Coloca la cadena sobre los dientes del plato. Retira las manos antes de girar lentamente la biela con la rueda trasera levantada.','action2'),
 step('action2','Comprueba que la cadena está asentada y circula sin engancharse, saltar ni volver a salir.','worked')],[],[],(5,15),
 'Con frenos y dirección comprobados, en zona despejada prueba pedaleo suave y cambios. ¿La cadena permanece asentada, sin saltos ni nueva salida, y puedes frenar normalmente?'),
 procedure('tube','Ponchadura: cambiar una cámara','Llanta pierde aire: sustitución de cámara en cubierta convencional.','wheels',['ponchadura','llanta pierde aire','neumático desinflado'], 'Cubierta con cámara confirmada; no tubeless ni tubular',
 '¿Confirmas cámara, repuesto de medida y válvula correctas según sus etiquetas, presión aplicable documentada por fabricantes de llanta/rin y método de desmontaje y montaje de tu rueda conocido? Si falta cualquier dato, detente.',
 [step('action0','Retira la rueda conforme a las instrucciones de su fabricante. No acciones un freno de disco con la rueda fuera. Desinfla completamente; desmonta el talón con desmontables, nunca objetos cortantes. Extrae la cámara.','inspect'),
 check('inspect','Inspecciona cubierta, talones, rin y cinta. Retira el objeto causante. ¿Todo está íntegro y sin objetos punzantes restantes?','action1'),
 step('action1','Da forma a la cámara nueva con un poco de aire. Coloca válvula recta y cámara sin torsión. Monta el talón sin pellizcarla; verifica todo el contorno.','seated'),
 check('seated','¿La cámara está dentro, sin quedar atrapada bajo el talón?','action2'),
 step('action2','Infla gradualmente a la presión documentada para tu combinación, respetando ambos límites. Comprueba asiento uniforme. Reinstala y asegura la rueda conforme a su fabricante; reconecta el freno si corresponde.','worked')],['pump','levers','axle'],['tube'],(20,45),
 'Comprueba rueda asegurada, talón uniforme, ausencia de fuga y funcionamiento de ambos frenos. Después de una prueba suave en zona despejada, vuelve a medir. ¿Mantiene la presión elegida sin deformación ni roce?'),
 procedure('index','Cambios traseros mal indexados','Ajuste menor de tensión de cable; no corrige límites, desgaste ni piezas dobladas.','drivetrain',['cambio no entra','cambios lentos','cadena brinca'], 'Cambio mecánico por cable convencional: al tensar sube a piñones mayores',
 '¿Confirmas sistema sin motor, tensor identificado, patilla sin deformación visible, cable íntegro, rueda asegurada y límites ya verificados por mecánico? Excluye golpes, repuestos recién instalados, salto bajo carga y problemas de extremos.',
 [step('action0','Sostén la bicicleta con la rueda trasera libre. En dos platos usa el grande; en tres, el intermedio. Desde el piñón menor, pedalea a mano y manda un clic. Mantén manos lejos de la transmisión.','direction'),
 dict(id='direction',kind='check',text='¿Qué ocurre con ese clic?',choices=[choice('slow','No sube al siguiente piñón','action1'),choice('over','Sube dos piñones','action2'),choice('unknown','Otro resultado / No sé','stop')]),
 step('action1','Vuelve al cambio inicial. Desenrosca el tensor una vuelta (antihorario mirando su extremo). Si está próximo a salir o no gira libremente, detente. Repite la prueba una sola vez.','adjusted'),
 step('action2','Vuelve al cambio inicial. Enrosca el tensor una vuelta (horario mirando su extremo). Si hace tope, detente. Repite la prueba una sola vez.','adjusted'),
 check('adjusted','¿Pudiste ajustar sin forzar, sin llegar a tope y sin que el tensor quede próximo a salir?','worked')],['stand'],[],(10,25),
 'Con límites previamente verificados, comprueba todos los cambios en ambos sentidos sin saltos ni ruidos. Luego prueba pedaleo suave y frenado en lugar despejado. ¿Un clic produce un cambio y el síntoma no reaparece?'),
 procedure('disc','Freno de disco rozando','Centrado inicial de pinza hidráulica; excluye rotor deformado, holguras y pérdida de frenado.','brakes',['disco roza','freno rozando','rueda hace ruido'], 'Disco hidráulico con tornillos de fijación de pinza identificados',
 '¿Confirmas sistema, rueda bien asentada, sin holgura en rotor/buje, sin deformación visible, sin fuga y frenado normal? ¿Tienes manual exacto con torque y secuencia de fijación, y herramienta adecuada? Este piloto no purga ni endereza discos.',
 [step('action0','Espera a que el freno esté frío. Mantén dedos y herramientas fuera del rotor. Con la rueda parada, afloja solo los tornillos de montaje identificados hasta permitir movimiento lateral de la pinza.','action1'),
 step('action1','Aprieta la maneta para centrar la pinza. Manteniéndola, asienta los tornillos. Suelta la maneta y fija al torque y secuencia del fabricante de tu montaje; no uses un valor genérico.','secured'),
 check('secured','¿Los tornillos quedaron fijados exactamente como indica tu manual?','action2'),
 step('action2','Gira la rueda y observa, con luz detrás de la pinza, que el rotor no toca las pastillas. Si sigue rozando, este intento termina; no ajustes junto a la rueda girando.','worked')],['bits','torque','light','stand'],[],(15,30),
 'Acciona el freno varias veces; comprueba fijación, rueda libre, ausencia de fuga y tacto normal. Prueba ambos frenos a baja velocidad en zona despejada. ¿Frena normalmente y ya no roza?')]
from revise_phase3 import revise
revise(procedures, choice, check, step)
write('components',json.loads((ROOT/'knowledge/generated/development/0.1.0/components.json').read_text(encoding='utf-8-sig')))
write('manifest',dict(schemaVersion=2,componentsVersion='0.1.0',repairsVersion='0.3.1'))
write('repairs',dict(kind='repairs',schemaVersion=2,contentVersion='0.3.1',status='development',technicalVersion='0.1.0',locale='es-MX',sources=sources,synonyms=[['ponchadura','pinchazo'],['cadena caída','cadena salida']],
 tools=[dict(id=i,name=n) for i,n in [('pump','Bomba con manómetro y conexión para tu válvula'),('levers','Desmontables para llanta'),('axle','Herramienta para tu eje, si su fabricante la requiere'),('stand','Soporte estable que permita girar la rueda sin sujetarla a mano'),('bits','Llave y punta exactas para los tornillos de tu pinza'),('torque','Torquímetro adecuado al torque del manual de tu montaje'),('light','Lámpara para observar la separación')]],consumables=[dict(id='tube',name='Cámara nueva: medida y válvula verificadas para esta llanta y rin')],
 identifications=[dict(key=k,storageKey='knowledge.pilot_'+k,values={'known':p['nodes'][1]['choices'][0]['label'],'other':'Otro sistema','unknown':'No sé'}) for k,p in zip(['chain','tube','index','disc'],procedures)],procedures=procedures))
