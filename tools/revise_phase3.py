"""Product revision applied by the pilot builder; original offline content only."""
def revise(procedures, choice, check, step):
    help_text = {
      'chain': 'Busca el engrane junto a los pedales (plato) y el brazo con dos rueditas bajo los engranes traseros (cambio trasero). Este piloto solo recoloca cadenas enteras y libres, sin motor ni guía de cadena. Los dientes alternadamente anchos y estrechos necesitan una colocación específica: no la adivines.',
      'tube': 'La válvula por sí sola no demuestra que haya cámara. Busca un registro del montaje o confirmación de quien lo hizo. Compara la medida escrita en la cubierta y el rango de la cámara; comprueba también tipo y longitud de válvula. No deduzcas compatibilidad por apariencia.',
      'index': 'Busca el cable que llega al cambio trasero y la pieza roscada por donde entra (tensor). Un sistema electrónico no usa ese cable. Si no puedes confirmar cómo responde tu modelo al tensar el cable, consulta su identificación antes de ajustar.',
      'disc': 'La pieza que abraza el disco es la pinza. Una manguera hidráulica llega a ella; un cable visible sujeto a una palanca indica freno mecánico. El dibujo muestra la separación disco/pastillas, no identifica tornillos: para aflojarlos necesitas reconocer los de montaje en tu modelo.'}
    for p in procedures:
        key=p['id'].split('.')[-1]; ns=p['nodes']; n={v['id']:v for v in ns}
        n['identify']['choices'][1]['next']='stop'
        n['identify']['choices'][2]['next']='identify_help'
        ns.append(check('identify_help',help_text[key]+' ¿Ahora puedes confirmar el sistema descrito?', 'scope'))
        n['complete']['text']='La comprobación mecánica y la prueba final fueron satisfactorias dentro del alcance del piloto. Si reaparece el síntoma, detente para revisar la causa.'
        n['worked']['text']={
          'chain':'Al girar a mano, ¿la cadena sigue sobre los dientes, sin saltar ni salirse?',
          'tube':'¿La rueda quedó asegurada, la línea junto al borde de la cubierta es uniforme en ambos lados y conserva el aire?',
          'index':'Al pedalear a mano, ¿cada clic mueve la cadena al engrane vecino, sin saltos?',
          'disc':'Con los tornillos asegurados, ¿el disco gira sin tocar las pastillas?'}[key]
        n['worked']['choices'][1]['label']='No / necesito revisar otra causa'
        n['worked']['choices'][1]['next']='next_cause'
        n['scope']['choices'][1]['next']='scope_help'
        ns.append(check('scope_help','Revisa con la bicicleta inmóvil y buena luz. '+n['scope']['text']+' Si falta un dato específico, busca la etiqueta o documentación exacta; no uses valores de otro componente. ¿Puedes confirmar ahora estas condiciones?', 'context'))
        # Unknown identity is recoverable without modifying the profile.
        if key=='chain':
            n['identify']['choices'][0]['label']='Sin motor, con cambio trasero y plato sin guía ni dientes anchos/estrechos alternados'
            n['scope']['text']='¿La cadena está entera, libre, sin deformaciones y sigue sobre los engranes traseros? Si está atrapada o hay daño, no la fuerces.'
            n['action0']['text']='Con pedales inmóviles y bicicleta estable, mueve suavemente hacia delante el brazo con dos rueditas del cambio trasero (jaula) para dar holgura a la cadena. No fuerces si se resiste.'
            ns.extend([check('next_cause','La recolocación no resolvió la causa. No pedalees montado. Con todo inmóvil, mira si algún eslabón está torcido, la cadena está atrapada o hay dientes dañados. ¿Está entera y libre, sin daño visible?', 'chain_position'),
              check('chain_position','Observa desde arriba, sin tocar ajustes: ¿la cadena quedó a un lado de los dientes en vez de apoyada sobre ellos?', 'retry_chain','chain_manual_check'),
              check('chain_manual_check','Con las manos lejos, gira lentamente las bielas dos vueltas con la rueda trasera levantada. ¿La cadena permanece sobre los dientes, sin engancharse ni saltar?', 'final'),
              step('retry_chain','Repite una vez la colocación: da holgura con el brazo del cambio, apoya la cadena en los dientes y retira las manos antes de girar a mano. No ajustes tornillos del cambio.','retry_check'),
              check('retry_check','¿Ahora permanece sobre los dientes al girar a mano, sin saltos ni salida?', 'final')])
        elif key=='index':
            p['title']='[PRUEBA] Cambios traseros: un clic no cambia bien'
            n['scope']['text']='¿Es un sistema sin motor, sin golpes recientes ni piezas recién cambiadas, y la cadena no salta al hacer fuerza?'
            n['scope']['choices'][0]['next']='wheel_check'
            ns[-1]['choices'][0]['next']='wheel_check'
            ns.extend([check('wheel_check','Con la rueda quieta, comprueba que está bien asentada y sujeta. ¿Está firme, sin movimiento lateral?', 'cable_check'),
              check('cable_check','Mira el cable y su funda: ¿están enteros, sin hilos rotos y con sus extremos asentados?', 'hanger_check'),
              check('hanger_check','Mira la pieza que une el cambio al cuadro (patilla). ¿No ves deformación y el cambio está lejos de los radios? La vista no certifica su alineación.', 'limits_check'),
              check('limits_check','¿Los topes que impiden salir de los engranes extremos ya fueron comprobados y no hay fallos en esos extremos? Si no lo sabes, no pruebes allí ni toques tornillos H/L/B.', 'context'),
              check('next_cause','El tensor no resolvió el cambio. Con todo inmóvil, revisa si una funda salió de su apoyo. ¿Ves un extremo fuera, sin cable roto ni daño?', 'housing'),
              step('housing','Sin aflojar el cable ni tocar topes, devuelve suavemente la funda a su apoyo si entra sin forzar. Si no entra, termina el ajuste y solicita revisión.','housing_check'),
              check('housing_check','¿La funda está asentada y un clic mueve la cadena al engrane vecino al girar a mano?', 'final')])
            n['direction']['choices'][2]['next']='next_cause'
        elif key=='tube':
            n['action0']['text']='Suelta el freno de rin si impide sacar la rueda. En rueda trasera, pasa al engrane pequeño. Abre el cierre o retira el eje según su sistema y saca la rueda sin forzar; si no reconoces ese montaje, consulta su manual antes de soltarlo. No acciones el freno de disco sin rueda. Vacía todo el aire: en válvula fina abre la tuerca de la punta y presiónala; en válvula tipo auto presiona su centro. Si no identificas la válvula, pide ayuda.'
            n['action0']['next']='remove_tire'
            ns.extend([step('remove_tire','Aprieta los costados de la cubierta para llevar sus bordes rígidos (talones) al canal central del rin. Mete un desmontable bajo un borde, sin atrapar la cámara; levanta ese borde sobre el rin y avanza poco a poco. Usa solo desmontables, nunca objetos cortantes. Si exige fuerza excesiva, detente y revisa que esté totalmente desinflada.','extract'),
              step('extract','Con un costado fuera, extrae la cámara empezando lejos de la válvula; saca la válvula al final. Retira el otro borde de la cubierta para inspeccionar el interior con luz. No pases la mano sobre objetos punzantes.','inspect'),
              check('next_cause','No circules con pérdida de aire o montaje dudoso. Sin desmontar, comprueba la conexión de la bomba y vuelve a medir. ¿El montaje está uniforme, la rueda firme y mantiene la presión aplicable?', 'final')])
            n['action1']['text']='Monta un borde de la cubierta en el rin respetando la flecha de giro si la hay. Da apenas forma a la cámara con aire, introduce la válvula recta y acomoda la cámara sin torcerla. Mete el segundo borde con las manos por tramos, manteniendo lo ya montado en el canal central. Evita palanquear sobre la cámara. Recorre ambos lados separando un poco la cubierta para ver que la cámara no asome bajo el borde.'
            n['seated']['choices'][1]['next']='reseat'
            ns.extend([step('reseat','Vacía el aire. Libera el tramo que atrapa la cámara, acomódala dentro y vuelve a montar el borde con las manos. No infles mientras asome cámara.','reseat_check'),check('reseat_check','¿La cámara está completamente dentro, sin pellizco visible en ambos lados?', 'action2')])
        else:
            n['action2']['text']='Con las manos y herramientas lejos del disco, gira la rueda y mira con luz detrás de la pinza. Observa si el roce es continuo o aparece solo en una parte de la vuelta. Para tocar cualquier pieza, para primero la rueda.'
            ns.extend([check('next_cause','El centrado no eliminó el roce. ¿La rueda sigue firme, el freno tiene tacto normal y no hay fuga, disco deformado ni tornillos flojos?', 'rub_pattern'),
              dict(id='rub_pattern',kind='check',text='Observa a distancia mientras gira; detén la rueda antes de intervenir. ¿Cómo roza?',choices=[choice('yes','Roza de forma continua; montaje y torque siguen confirmados','retry_disc'),choice('other','Solo en parte de la vuelta / no puedo distinguirlo','stop')]),
              step('retry_disc','Repite el centrado una sola vez con rueda inmóvil: afloja únicamente los tornillos de montaje identificados, aprieta la maneta, asienta los tornillos y termina con torque y secuencia de tu montaje. No abras la pinza ni ajustes con el disco girando.','retry_secured'),
              check('retry_secured','¿Los tornillos quedaron asegurados según el montaje específico?', 'retry_check'),
              check('retry_check','¿Ahora gira sin tocar las pastillas y mantiene tacto normal?', 'final')])
        visual={'chain':'chain_arm','index':'chain_arm','tube':'tube_bead','disc':'disc_gap'}[key]
        for node in ns:
            if node['id']=='scope_help':
                node['text']='Con la bicicleta inmóvil y buena luz, revisa lo indicado sin aflojar piezas. '+n['scope']['text']+' Si falta identificar un dato específico, busca la etiqueta o documentación de ese componente. ¿Puedes confirmarlo ahora?'
            if node['id'] in ['identify_help','action0' if key=='chain' else 'remove_tire' if key=='tube' else 'hanger_check' if key=='index' else 'action2']:
                node['visualIds']=[visual]
