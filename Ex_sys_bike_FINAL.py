"""Sistema experto integral de bicicletas — prototipo V2.

Para ciclistas ocasionales, urbanos, deportivos y profesionales. Incluye
triaje, bicicletas convencionales/e-bike, componentes genéricos o de marca,
reglas hacia adelante, Bayes, Mamdani y encadenamiento hacia atrás.

Ejecutar:
    python Ex_sys_bike_FINAL.py
    python Ex_sys_bike_FINAL.py --self-test

AVISO: orientación educativa; no sustituye inspección física ni manuales.
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Set, Tuple

Option = Tuple[str, str]

PROFILES: Tuple[Option, ...] = (
    ("ocasional", "Ocasional: paseos y mandados"),
    ("recreativo", "Recreativo frecuente"),
    ("urbano", "Urbano/commuter diario"),
    ("viajero", "Cicloturismo o bikepacking"),
    ("deportivo", "Entrenamiento/amateur"),
    ("mtb", "MTB técnico, enduro o descenso"),
    ("pro", "Competidor avanzado o profesional"),
    ("trabajo", "Reparto, carga o uso laboral"),
    ("menor", "Niña/niño con supervisión adulta"),
)

BIKES: Tuple[Option, ...] = (
    ("urbana", "Urbana, paseo o cruiser"), ("hibrida", "Híbrida/fitness"),
    ("ruta", "Ruta"), ("gravel", "Gravel/ciclocross"),
    ("mtb_ht", "MTB rígida/hardtail"), ("mtb_full", "MTB doble suspensión"),
    ("bmx", "BMX, dirt jump o trial"), ("touring", "Touring/bikepacking"),
    ("plegable", "Plegable"), ("cargo", "Cargo, triciclo o reparto"),
    ("infantil", "Infantil"), ("tandem", "Tándem"),
    ("reclinada", "Reclinada"), ("fixie", "Pista, fixie o single-speed"),
    ("ebike_urbana", "E-bike urbana/cargo"), ("ebike_mtb", "E-MTB"),
    ("ebike_ruta", "E-road/e-gravel"), ("otra", "Otra o personalizada"),
)

MATERIALS: Tuple[Option, ...] = (
    ("acero", "Acero"), ("aluminio", "Aluminio"),
    ("carbono", "Fibra de carbono"), ("titanio", "Titanio"),
    ("mixto", "Mixto o desconocido"),
)
CONTEXTS: Tuple[Option, ...] = (
    ("casa", "En casa/antes de salir"), ("ruta", "Durante una ruta"),
    ("entreno", "Durante entrenamiento"), ("carrera", "Competencia"),
    ("trabajo", "Traslado, reparto o trabajo"),
)
TOOLS: Tuple[Option, ...] = (
    ("0", "Ninguna"), ("1", "Básica: bomba, parches y multiherramienta"),
    ("2", "Intermedia: taller doméstico y torquímetro"),
    ("3", "Profesional: herramienta específica y medición"),
)
SYSTEMS: Tuple[Option, ...] = (
    ("ruedas", "Ruedas, llantas o neumáticos"), ("frenos", "Frenos"),
    ("transmision", "Transmisión y cambios"),
    ("direccion", "Dirección, manubrio u horquilla rígida"),
    ("suspension", "Suspensión"), ("cuadro", "Cuadro, pivotes o tija"),
    ("electrico", "Motor, batería o sistema eléctrico"),
)

CONFIG: Dict[str, Tuple[str, Tuple[Option, ...]]] = {
    "ruedas": ("Sistema de neumático", (("camara", "Con cámara"), ("tubeless", "Tubeless"), ("tubular", "Tubular"), ("solido", "Sólido"), ("?", "Desconocido"))),
    "frenos": ("Tipo de freno", (("rin", "De rin"), ("mecanico", "Disco mecánico"), ("hidraulico", "Disco hidráulico"), ("interno", "Contrapedal/tambor"), ("?", "Desconocido"))),
    "transmision": ("Tipo de transmisión", (("mecanica", "Desviador mecánico"), ("electronica", "Electrónica/inalámbrica"), ("interna", "Maza interna/CVT"), ("single", "Single-speed/fixie"), ("?", "Otra"))),
    "direccion": ("Material de cockpit", (("aluminio", "Aluminio"), ("carbono", "Carbono"), ("acero", "Acero"), ("?", "Desconocido"))),
    "suspension": ("Tecnología de suspensión", (("aire", "Aire"), ("resorte", "Resorte/coil"), ("electronica", "Electrónica"), ("?", "Desconocida"))),
    "cuadro": ("Zona del cuadro", (("tubo", "Tubo/soldadura"), ("pivote", "Pivote"), ("tija", "Tija"), ("direccion", "Caja de dirección"), ("pedalier", "Pedalier"), ("otra", "Otra"))),
    "electrico": ("Arquitectura eléctrica", (("central", "Motor central"), ("maza_d", "Maza delantera"), ("maza_t", "Maza trasera"), ("integrada", "Ligera integrada"), ("?", "Desconocida"))),
}

BRANDS: Dict[str, Tuple[Option, ...]] = {
    "ruedas": (("generico", "Genérico"), ("shimano", "Shimano"), ("sram", "SRAM/Zipp"), ("campagnolo", "Campagnolo/Fulcrum"), ("dt", "DT Swiss"), ("mavic", "Mavic"), ("otra", "Otra")),
    "frenos": (("generico", "Genérico"), ("shimano", "Shimano"), ("sram", "SRAM/Avid"), ("campagnolo", "Campagnolo"), ("magura", "Magura"), ("tektro", "Tektro/TRP"), ("hope", "Hope"), ("otra", "Otra")),
    "transmision": (("generico", "Genérico"), ("shimano", "Shimano"), ("sram", "SRAM"), ("campagnolo", "Campagnolo"), ("microshift", "microSHIFT"), ("rohloff", "Rohloff/Enviolo"), ("otra", "Otra")),
    "direccion": (("generico", "Genérico"), ("fsa", "FSA/Vision"), ("ritchey", "Ritchey"), ("raceface", "Race Face/Easton"), ("deda", "Deda"), ("otra", "Otra")),
    "suspension": (("generico", "Genérica"), ("fox", "FOX"), ("rockshox", "RockShox"), ("suntour", "SR Suntour"), ("marzocchi", "Marzocchi"), ("manitou", "Manitou"), ("ohlins", "Öhlins"), ("otra", "Otra")),
    "cuadro": (("generico", "Genérico"), ("fabricante", "Fabricante identificable"), ("artesanal", "Artesanal/personalizado"), ("otra", "Otro")),
    "electrico": (("generico", "Kit genérico"), ("bosch", "Bosch"), ("shimano", "Shimano STEPS"), ("brose", "Brose/Specialized"), ("yamaha", "Yamaha/Giant"), ("bafang", "Bafang"), ("fazua", "Fazua"), ("tq", "TQ"), ("otra", "Otra")),
}


@dataclass(frozen=True)
class Scenario:
    key: str
    system: str
    label: str
    diagnosis: str
    action: str
    risk: str = "medio"
    complexity: int = 1
    bayes: Optional[str] = None
    manual_fact: Optional[str] = None


def S(key: str, system: str, label: str, diagnosis: str, action: str,
      risk: str = "medio", complexity: int = 1,
      bayes: Optional[str] = None, manual: Optional[str] = None) -> Scenario:
    return Scenario(key, system, label, diagnosis, action, risk, complexity, bayes, manual)


SCENARIOS: Tuple[Scenario, ...] = (
    # Ruedas
    S("ponchadura", "ruedas", "Ponchadura o pérdida rápida", "Perforación, pellizco, válvula o pérdida de sellado.", "Inspecciona cubierta, cámara/válvula y fondo de rin; en tubeless revisa sellador y cinta.", "medio", 1, "reincidencia"),
    S("pierde_aire", "ruedas", "Pérdida lenta de aire", "Microfuga, válvula, cinta tubeless o material envejecido.", "Mide la pérdida y localiza con agua jabonosa; corrige según el sistema y su presión límite.", "bajo", 1, "reincidencia", "valvula_floja"),
    S("rayos", "ruedas", "Rayo roto/flojo o rueda descentrada", "Tensión de rayos irregular.", "Asegura el rayo suelto, evita cargas y realiza sustitución, tensado y centrado medido.", "alto", 2),
    S("rin", "ruedas", "Rin doblado, golpeado o agrietado", "Posible deformación o falla estructural.", "No lo golpees. Con grieta o deformación severa, sustituye y no circules.", "critico", 3),
    S("maza", "ruedas", "Juego, aspereza o ruido en maza", "Rodamiento, cono, eje o núcleo desgastado/flojo.", "Comprueba juego y giro; ajusta o sustituye con el procedimiento de la maza exacta.", "alto", 2),
    S("vibracion", "ruedas", "Vibración o salto a velocidad", "Cubierta mal asentada, carcasa dañada o rueda fuera de centro.", "Reduce velocidad; no uses una cubierta con bulto, corte o alambre expuesto.", "alto", 2),
    # Frenos
    S("sin_freno", "frenos", "No frena/maneta al fondo", "Pérdida crítica por fuga, cable, aire, desgaste o ajuste.", "No uses la bicicleta; revisa ambos circuitos y repara antes de una prueba controlada.", "critico", 3),
    S("debil", "frenos", "Frenado débil", "Contaminación, desgaste, alineación, cable o aire.", "Mide desgaste, limpia con producto compatible y corrige alineación/purga.", "alto", 2),
    S("roce", "frenos", "Freno roza", "Rueda, disco/rin, pistones o zapatas desalineados.", "Confirma fijación de rueda y centra; no endereces una pieza fisurada.", "medio", 1),
    S("ruido", "frenos", "Chirrido, vibración o pulsación", "Contaminación, cristalización, montaje o superficie irregular.", "Inspecciona torque y desgaste; sustituye si hay grieta o espesor fuera de límite.", "medio", 2),
    S("fuga", "frenos", "Fuga o maneta esponjosa", "Aire, manguera/sello o líquido incorrecto.", "No circules ni mezcles DOT con aceite mineral; repara y purga con kit compatible.", "critico", 3),
    S("cable", "frenos", "Cable duro, deshilachado o roto", "Cable/funda corroídos o dañados.", "Sustituye cable y funda; ajusta tensión y cierre. No reutilices cable dañado.", "alto", 2),
    S("calor", "frenos", "Sobrecalentamiento/fading", "Temperatura excesiva, material o dimensionamiento insuficiente.", "Detente y deja enfriar sin tocar ni echar agua; revisa antes de descender otra vez.", "critico", 3),
    # Transmisión
    S("cadena_sale", "transmision", "Cadena se sale", "Ajuste, desgaste, línea de cadena o patilla.", "No pedalees fuerte; recoloca solo sin daño y revisa topes, guía y desgaste.", "medio", 1, None, "cadena_salida"),
    S("cadena_rota", "transmision", "Cadena rota/eslabón dañado", "Desgaste, unión incorrecta o sobrecarga.", "Usa eslabón/pasador compatible con marca y velocidades; revisa cassette/platos.", "alto", 2),
    S("salta", "transmision", "Cadena salta bajo carga", "Cadena/cassette/plato, núcleo o ajuste.", "Evita sprints; mide desgaste e identifica la pieza antes de sustituir el conjunto.", "alto", 2),
    S("cambio", "transmision", "Cambios imprecisos o ruidosos", "Indexado, patilla, cables, batería o incompatibilidad.", "Comprueba patilla y rueda; confirma velocidades, tiro de cable o firmware.", "medio", 2),
    S("electronico", "transmision", "Cambio electrónico no responde", "Carga, emparejamiento, conector, firmware o motor.", "Carga, revisa conectores y códigos; no fuerces el desviador.", "medio", 2),
    S("bielas", "transmision", "Crujido/juego en bielas o eje", "Pedal, tornillo, plato, biela o eje de centro.", "Aísla la fuente y comprueba juego/torque; no aprietes de más.", "alto", 2, "eje"),
    S("nucleo", "transmision", "Núcleo/cassette patina", "Trinquetes, rodamiento, cassette o maza dañados.", "No pedalees con carga; el servicio depende del núcleo exacto.", "alto", 3),
    S("single", "transmision", "Cadena floja/tensa en single/fixie", "Tensión, alineación, eje o excentricidad.", "Ajusta en el punto más tenso; en fixie confirma piñón y contratuerca.", "alto", 2),
    # Dirección
    S("juego", "direccion", "Juego en dirección/manubrio", "Precarga, rodamientos o fijación.", "No uses a velocidad; ajusta en orden correcto y con torque especificado.", "critico", 2, "direccion"),
    S("dura", "direccion", "Dirección dura o trabada", "Rodamientos, cables, bloqueo o impacto.", "No circules hasta recuperar giro libre; sustituye piezas marcadas o deformadas.", "critico", 3),
    S("desalineada", "direccion", "Manubrio/rueda desalineados", "Potencia girada o pieza doblada.", "Descarta daño, alinea y aplica torque; cuidado especial con carbono.", "alto", 2),
    S("manubrio", "direccion", "Manubrio/potencia doblado o agrietado", "Pérdida de integridad estructural.", "No uses ni endereces; sustituye y revisa horquilla/dirección.", "critico", 3),
    S("horquilla", "direccion", "Horquilla rígida doblada/fisurada", "Puede fallar súbitamente.", "No uses; sustituye por una compatible e inspecciona el cuadro.", "critico", 3),
    S("controles", "direccion", "Puños/acoples/controles se mueven", "Fijación, diámetro o contacto incorrectos.", "Confirma diámetro y torque; no excedas torque, sobre todo en carbono.", "alto", 2),
    # Suspensión
    S("sag", "suspension", "Sag excesivo o insuficiente", "Presión/resorte, volumen o precarga incorrectos.", "Mide sag equipado y ajusta con la tabla del modelo, sin exceder límites.", "medio", 2),
    S("fuga", "suspension", "Pierde aceite o aire", "Sellos, válvula, vástago o cámara.", "Localiza la fuga; no abras una cámara presurizada sin capacitación.", "alto", 3),
    S("bloqueada", "suspension", "Sin recorrido/bloqueada", "Bloqueo, presión, cartucho o control electrónico.", "No fuerces; identifica modelo/año y realiza diagnóstico específico.", "alto", 3),
    S("tope", "suspension", "Hace tope con frecuencia", "Ajuste, resorte, volumen o compresión insuficientes.", "Registra sag/recorrido e inspecciona tras impactos antes de saltar.", "alto", 2),
    S("ruido", "suspension", "Golpeteo o ruido interno", "Servicio, bujes, fijación o daño interno.", "Aísla el ruido; detén uso agresivo si hay juego o metal con metal.", "alto", 3),
    S("pivotes", "suspension", "Juego lateral en suspensión", "Rodamientos, bujes, tornillos o anclaje.", "No saltes/desciendas; localiza juego y usa secuencia/torque del cuadro.", "critico", 3),
    # Cuadro
    S("grieta", "cuadro", "Grieta, separación o delaminación", "Posible falla estructural.", "No uses ni lijes; documenta y solicita evaluación del fabricante/especialista.", "critico", 3),
    S("golpe", "cuadro", "Abolladura, impacto o fibra marcada", "Daño cosmético o estructural según zona/material.", "Suspende uso intenso; inspección obligatoria cerca de uniones y zonas blandas.", "alto", 3),
    S("corrosion", "cuadro", "Óxido/corrosión", "Corrosión superficial o pérdida de espesor.", "Evalúa profundidad; corrosión perforante o en uniones retira la bici de servicio.", "alto", 2),
    S("tija", "cuadro", "Tija atorada, baja o tiene juego", "Diámetro, compuesto, abrazadera o tija.", "Confirma diámetro/inserción; no excedas torque ni improvises calor.", "alto", 2),
    S("pivote", "cuadro", "Pivote/tornillo flojo", "Torque, rosca, fijador o rodamiento.", "No uses en terreno técnico; sigue secuencia/torque y cambia hardware dañado.", "critico", 3),
    S("alineacion", "cuadro", "Bicicleta no rueda recta", "Rueda, patilla, horquilla o cuadro desalineados.", "Descarta componentes; cuadro/horquilla requieren medición profesional.", "alto", 3),
    # Eléctrico
    S("no_enciende", "electrico", "No enciende", "Carga, conexión, activación o error.", "Reinstala batería solo si el manual permite; revisa carga/códigos, nunca puentes terminales.", "medio", 2),
    S("autonomia", "electrico", "Autonomía reducida", "Temperatura, presión, frenos, carga o envejecimiento.", "Compara condiciones y diagnostica salud/ciclos; no abras el paquete.", "medio", 2),
    S("caliente", "electrico", "Batería caliente, hinchada, con olor/humo", "Riesgo térmico o daño interno.", "Apaga, aléjate y no cargues/manipules. Con humo/fuego evacúa y llama a emergencias.", "critico", 3),
    S("motor", "electrico", "Motor ruidoso o sin asistencia", "Sensor, rodamiento, engrane, cable o controlador.", "Detén asistencia, registra código y usa servicio del sistema exacto.", "alto", 3),
    S("sensor", "electrico", "Asistencia intermitente/error", "Sensor, imán, conexión o firmware.", "Revisa alineación/conectores; no anules sensores y usa diagnóstico oficial.", "alto", 2),
    S("carga", "electrico", "No carga/cargador marca error", "Toma, cargador, puerto, temperatura o batería.", "Usa solo cargador compatible y supervisado; con calor/olor desconecta.", "critico", 3),
    S("agua", "electrico", "Inundada o lavada a presión", "Agua en batería, conectores, motor o control.", "Apaga y no cargues; no uses calor ni abras batería, solicita evaluación.", "critico", 3),
)

BY_SYSTEM = {key: tuple(s for s in SCENARIOS if s.system == key) for key, _ in SYSTEMS}
RISK_ACTION = {
    "bajo": "Evaluar con precaución antes del siguiente uso.",
    "medio": "Evitar uso exigente hasta verificar la corrección.",
    "alto": "Limitar o suspender el uso hasta inspección y reparación.",
    "critico": "NO UTILIZAR hasta inspección y reparación satisfactoria.",
}


class ScenarioEngine:
    def infer(self, system: str, symptom: str) -> Scenario:
        for item in SCENARIOS:
            if item.system == system and item.key == symptom:
                return item
        raise LookupError("Escenario no catalogado")


BRAND_NOTES = {
    "generico": "No asumas compatibilidad por apariencia: mide estándar, dimensiones e interfaz.",
    "shimano": "Identifica código/serie Shimano y confirma velocidades, interfaz, fluido y procedimiento.",
    "sram": "Distingue familia/generación SRAM, velocidades y sistema mecánico, eTap/AXS o Transmission.",
    "campagnolo": "Confirma grupo/generación Campagnolo, cuerpo libre, velocidades y herramienta específica.",
    "microshift": "Confirma familia microSHIFT, velocidades y relación de tiro.",
    "rohloff": "Rohloff/Enviolo requiere aceite, cableado e interfaz propios del modelo.",
    "fox": "Registra modelo, año, recorrido e ID FOX; presión, kits e intervalos son específicos.",
    "rockshox": "Registra modelo/año/serial RockShox, recorrido y cartucho antes de ajustar o servir.",
    "suntour": "Identifica modelo y cartucho SR Suntour; presión, resorte y repuestos varían.",
    "marzocchi": "Verifica modelo/año y número de parte Marzocchi; no presupongas kits compatibles.",
    "manitou": "Confirma modelo, recorrido y sistema Manitou antes de servicio.",
    "ohlins": "Usa especificaciones Öhlins exactas; servicio interno por personal preparado.",
    "magura": "Confirma modelo MAGURA, aceite, pastilla y espesor mínimo.",
    "tektro": "Distingue Tektro/TRP, fluido, pastilla, rotor y adaptador.",
    "hope": "Identifica generación Hope, fluido, pistones y rotor.",
    "bosch": "Registra código y generación Bosch; batería/cargador/firmware deben corresponder.",
    "brose": "Registra bicicleta y unidad Brose/Specialized; usa diagnóstico del fabricante.",
    "yamaha": "Confirma generación Yamaha/Giant, batería y display; no mezcles cargadores.",
    "bafang": "Identifica motor/control Bafang, voltaje y protocolo; no alteres parámetros de seguridad.",
    "fazua": "Registra generación y códigos Fazua; sigue su flujo de diagnóstico.",
    "tq": "Identifica sistema TQ y fabricante; firmware, batería y sensores están integrados.",
}


def compatibility(system: str, brand: str, model: str) -> List[str]:
    label = dict(BRANDS[system]).get(brand, brand)
    lines = [f"Componente: {label}" + (f" | Modelo/serie: {model}" if model else ""),
             BRAND_NOTES.get(brand, "Busca manual y tabla de compatibilidad del modelo exacto.")]
    extra = {
        "ruedas": "Confirma ETRTO, ancho, eje, núcleo, radios y límites de presión/carga.",
        "frenos": "Nunca mezcles DOT y aceite mineral; confirma pastilla, rotor y espesor mínimo.",
        "transmision": "Confirma velocidades, cadena, cassette/cuerpo, tiro de cable o protocolo electrónico.",
        "direccion": "Confirma diámetros, dirección, sujeción y torque, especialmente en carbono.",
        "suspension": "Confirma recorrido, offset, montaje, presión, hardware y cuadro/rueda/freno.",
        "cuadro": "Material, ubicación y fabricante determinan si el daño es reparable.",
        "electrico": "No intercambies batería/cargador/display/control solo porque el conector coincide.",
    }
    return lines + [extra[system]]


def audience_note(profile: str, bike: str, context: str, risk: str) -> str:
    if profile == "pro":
        return "Competición: registra torque, desgaste y tolerancias; prueba controlada y autorización mecánica antes de máxima intensidad."
    if profile == "mtb":
        return "MTB técnico: inspecciona tras impactos y no regreses a saltos/descenso sin verificar estructura, frenos, dirección y suspensión."
    if profile in {"urbano", "trabajo"} or bike == "cargo":
        return "Uso diario/carga: revisa ambos frenos, ruedas y capacidad de carga; programa mantenimiento preventivo."
    if profile == "viajero":
        return "Larga distancia: corrige la causa raíz, lleva repuestos compatibles y prueba con carga."
    if profile == "menor" or bike == "infantil":
        return "Una persona adulta debe revisar y probar; ante dudas, acudir a taller."
    if context == "ruta" and risk in {"alto", "critico"}:
        return "En ruta no improvises: busca transporte o asistencia."
    return "Si el síntoma persiste o no identificas el estándar, acude a un taller."


RED_FLAGS: Tuple[Option, ...] = (
    ("ninguna", "Ninguna"), ("impacto", "Choque/caída fuerte"),
    ("estructura", "Grieta, pieza doblada o fibra blanda"),
    ("freno", "Pérdida total/impredecible de frenado"),
    ("direccion", "Dirección suelta/trabada o parte rota"),
    ("bateria", "Batería caliente, hinchada, olor o humo"),
)
RED_ACTION = {
    "impacto": "Suspende uso y revisa cuadro, horquilla, ruedas, cockpit y frenos.",
    "estructura": "No cargues la zona; requiere evaluación estructural.",
    "freno": "No circules ni a baja velocidad; repara y prueba ambos frenos.",
    "direccion": "No circules: puede causar pérdida inmediata de control.",
    "bateria": "Apaga, aléjate y no cargues/abras; con humo o fuego evacúa y llama a emergencias.",
}


@dataclass
class Report:
    sections: List[Tuple[str, List[str]]] = field(default_factory=list)
    created: datetime = field(default_factory=datetime.now)

    def add(self, title: str, *lines: object) -> None:
        self.sections.append((title, [str(x).strip() for x in lines if str(x).strip()]))

    def render(self) -> str:
        out = ["SISTEMA EXPERTO INTEGRAL DE BICICLETAS — V2",
               f"Fecha: {self.created:%Y-%m-%d %H:%M}", "=" * 62]
        for title, lines in self.sections:
            out += ["", title.upper(), "-" * len(title)] + lines
        out += ["", "ALCANCE", "-------",
                "Orientación basada en respuestas; no confirma integridad, compatibilidad ni reparación sin inspección física y manual exacto."]
        return "\n".join(out) + "\n"


@dataclass(frozen=True)
class BayesModel:
    title: str; hypothesis: str; question: str; prior: float; yes_lr: float; no_lr: float

BAYES = {
    "reincidencia": BayesModel("Bayes — pérdida de aire", "causa persistente", "¿Ya ocurrió recientemente o vuelve tras repararlo?", .30, 3.2, .45),
    "direccion": BayesModel("Bayes — dirección", "rodamientos/superficies dañados", "¿Hay juego, golpeteo o punto duro?", .25, 3.0, .40),
    "eje": BayesModel("Bayes — eje de centro", "eje/rodamiento requiere servicio", "¿Persiste tras descartar pedales y tornillos?", .25, 2.8, .50),
}


def bayes_update(model: BayesModel, yes: bool) -> Tuple[float, List[str]]:
    odds = model.prior / (1 - model.prior) * (model.yes_lr if yes else model.no_lr)
    posterior = odds / (1 + odds)
    level = "BAJO" if posterior < .3 else "MEDIO" if posterior < .6 else "ALTO"
    return posterior, [f"Hipótesis: {model.hypothesis}", f"Inicial: {model.prior:.1%}",
                       f"Evidencia: {'Sí' if yes else 'No'}", f"Posterior: {posterior:.1%}",
                       f"Nivel: {level} (no sustituye inspección)."]


def tri(x: float, a: float, b: float, c: float) -> float:
    if x == b: return 1.0
    if x <= a or x >= c: return 0.0
    return (x-a)/(b-a) if x < b else (c-x)/(c-b)


def trap(x: float, a: float, b: float, c: float, d: float) -> float:
    if b <= x <= c: return 1.0
    if x <= a or x >= d: return 0.0
    return (x-a)/(b-a) if x < b else (d-x)/(d-c)


EXP: Dict[str, Callable[[float], float]] = {
    "Novata": lambda x: trap(x,0,0,1,3), "Intermedia": lambda x: tri(x,1,4,7),
    "Experta": lambda x: trap(x,5,7,10,10)}
TLS: Dict[str, Callable[[float], float]] = {
    "Nada": lambda x: tri(x,-1,0,1), "Basica": lambda x: tri(x,0,1,2),
    "Intermedia": lambda x: tri(x,1,2,3), "Profesional": lambda x: tri(x,2,3,4)}
CMP: Dict[str, Callable[[float], float]] = {
    "Simple": lambda x: tri(x,-1,0,1), "Moderada": lambda x: tri(x,0,1,2),
    "Avanzada": lambda x: tri(x,1,2,3), "Critica": lambda x: tri(x,2,3,4)}
OUT: Dict[str, Callable[[float], float]] = {
    "Dificil": lambda x: trap(x,0,0,25,40), "Normal": lambda x: tri(x,30,50,70),
    "Facil": lambda x: trap(x,60,75,100,100)}


def fuzzy_rules() -> List[Tuple[str,str,str,str]]:
    result = []
    for ei,e in enumerate(EXP):
        for ti,t in enumerate(TLS):
            for ci,c in enumerate(CMP):
                capacity = ei + ti - ci
                out = "Dificil" if ci == 3 or (ti == 0 and ci >= 1) or capacity <= 0 else "Normal" if capacity <= 2 else "Facil"
                result.append((e,t,c,out))
    return result


class FuzzySystem:
    def evaluate(self, experience: float, tools: int, complexity: int) -> Tuple[float,str]:
        if not 0 <= experience <= 10 or tools not in range(4) or complexity not in range(4):
            raise ValueError("Entradas difusas fuera de rango")
        em={k:f(experience) for k,f in EXP.items()}; tm={k:f(tools) for k,f in TLS.items()}; cm={k:f(complexity) for k,f in CMP.items()}
        universe=list(range(101)); agg=[0.0]*101
        for e,t,c,o in fuzzy_rules():
            strength=min(em[e],tm[t],cm[c])
            if strength:
                for i,x in enumerate(universe): agg[i]=max(agg[i],min(strength,OUT[o](x)))
        if not sum(agg): raise RuntimeError("Ninguna regla difusa activada")
        score=sum(x*m for x,m in zip(universe,agg))/sum(agg)
        return score,max(OUT,key=lambda name:OUT[name](score))


@dataclass(frozen=True)
class GoalRule:
    conclusion: str; premises: Tuple[str,...]

GOALS=(GoalRule("manual_limitada",("cadena_salida","detenida","sin_dano")),
       GoalRule("manual_limitada",("valvula_floja","detenida","sin_dano")),
       GoalRule("sin_herramientas",("manual_limitada",)))


class Backward:
    def prove(self, goal: str, facts: Set[str]) -> Tuple[bool,List[str]]:
        trace=[]
        def visit(g: str, active: Set[str]) -> bool:
            if g in facts: trace.append(f"HECHO: {g}"); return True
            if g in active: return False
            candidates=[r for r in GOALS if r.conclusion==g]
            if not candidates: trace.append(f"SIN SOPORTE: {g}"); return False
            for r in candidates:
                trace.append(f"{g} REQUIERE {' Y '.join(r.premises)}")
                if all(visit(p,active|{g}) for p in r.premises): trace.append(f"DEMOSTRADO: {g}"); return True
            trace.append(f"NO DEMOSTRADO: {g}"); return False
        return visit(goal,set()),trace


class App:
    def __init__(self) -> None:
        import tkinter as tk
        from tkinter import scrolledtext,ttk
        self.root=tk.Tk(); self.root.title("Sistema experto integral — V2"); self.root.geometry("900x680")
        self.report=Report(); self.engine=ScenarioEngine(); self.fuzzy=FuzzySystem(); self.backward=Backward()
        frame=ttk.Frame(self.root,padding=14); frame.pack(fill="both",expand=True)
        ttk.Label(frame,text="Sistema experto integral de bicicletas",font=("TkDefaultFont",17,"bold")).pack(anchor="w")
        ttk.Label(frame,text="Uso ocasional → competición | bicicletas genéricas y sistemas específicos").pack(anchor="w",pady=(2,12))
        self.output=scrolledtext.ScrolledText(frame,wrap="word"); self.output.pack(fill="both",expand=True)
        bar=ttk.Frame(frame); bar.pack(fill="x",pady=(10,0))
        ttk.Button(bar,text="Nuevo diagnóstico",command=self.start).pack(side="left",padx=4)
        ttk.Button(bar,text="Guardar",command=self.save).pack(side="left",padx=4)
        ttk.Button(bar,text="Copiar reporte",command=self.copy_report).pack(side="left",padx=4)
        ttk.Button(bar,text="Salir",command=self.root.destroy).pack(side="right")
        self.show("Presiona 'Nuevo diagnóstico' para comenzar.")

    def show(self,text:str)->None:
        self.output.config(state="normal"); self.output.delete("1.0","end"); self.output.insert("1.0",text); self.output.config(state="disabled")
    def yes(self,title:str,q:str)->bool:
        from tkinter import messagebox
        return bool(messagebox.askyesno(title,q,parent=self.root))
    def choose(self,title:str,q:str,options:Sequence[Option])->str:
        from tkinter import simpledialog
        menu="\n".join(f"{i}. {v}" for i,(_,v) in enumerate(options,1))
        n=simpledialog.askinteger(title,f"{q}\n\n{menu}",parent=self.root,minvalue=1,maxvalue=len(options))
        if n is None: raise InterruptedError
        return options[n-1][0]
    def text(self,title:str,q:str)->str:
        from tkinter import simpledialog
        return (simpledialog.askstring(title,q,parent=self.root) or "").strip()
    @staticmethod
    def label(options:Sequence[Option],key:str)->str: return dict(options).get(key,key)

    def start(self)->None:
        from tkinter import messagebox,simpledialog
        self.report=Report()
        if not self.yes("Inicio","¿Hay un problema o comportamiento anormal?"): return
        try:
            profile=self.choose("Ciclista","Perfil de la persona usuaria:",PROFILES)
            bike=self.choose("Bicicleta","Tipo de bicicleta:",BIKES)
            context=self.choose("Contexto","¿Dónde apareció?",CONTEXTS)
            material=self.choose("Cuadro","Material principal:",MATERIALS)
            identity=self.choose("Bicicleta","¿Marca genérica o identificable?",(("generica","Genérica/sin identificación"),("especifica","Marca/modelo identificable"),("custom","Personalizada/artesanal")))
            bike_model=self.text("Bicicleta","Marca y modelo (opcional):") if identity!="generica" else "Genérica/no identificada"
            tools=int(self.choose("Herramientas","Disponibilidad:",TOOLS))
            system=self.choose("Sistema","Sistema afectado:",SYSTEMS)
            config_title,config_options=CONFIG[system]; config=self.choose("Configuración",config_title+":",config_options)
            brand=self.choose("Fabricante","Componente genérico o específico:",BRANDS[system])
            model=self.text("Componente","Grupo/modelo/serie/código visible (opcional):") if brand!="generico" else ""
            options=tuple((s.key,s.label) for s in BY_SYSTEM[system]); symptom=self.choose("Síntoma","Escenario más cercano:",options)
            red=self.choose("Seguridad","¿Existe una bandera roja?",RED_FLAGS)
            case=self.engine.infer(system,symptom); risk="critico" if red!="ninguna" else case.risk; complexity=3 if red!="ninguna" else case.complexity

            self.report.add("Perfil",f"Ciclista: {self.label(PROFILES,profile)}",f"Bicicleta: {self.label(BIKES,bike)}",f"Marca/modelo: {bike_model}",f"Material: {self.label(MATERIALS,material)}",f"Contexto: {self.label(CONTEXTS,context)}",f"Herramientas: {self.label(TOOLS,str(tools))}")
            self.report.add("Configuración",f"Sistema: {self.label(SYSTEMS,system)}",f"{config_title}: {self.label(config_options,config)}",*compatibility(system,brand,model))
            if red!="ninguna": self.report.add("Triaje crítico",f"Bandera roja: {self.label(RED_FLAGS,red)}",RED_ACTION[red],"DETENER EL USO")
            else: self.report.add("Triaje","No se declaró bandera roja adicional; no descarta daño oculto.")
            self.report.add("Reglas hacia adelante",f"Regla: {system.upper()}::{case.key.upper()}",f"Escenario: {case.label}",f"Diagnóstico: {case.diagnosis}",f"Acción: {case.action}",f"Riesgo: {risk.upper()} — {RISK_ACTION[risk]}",audience_note(profile,bike,context,risk))
            if case.bayes:
                bm=BAYES[case.bayes]; _,lines=bayes_update(bm,self.yes(bm.title,bm.question)); self.report.add(bm.title,*lines)
            if tools==0 or context=="ruta":
                facts={"detenida"}
                if case.manual_fact: facts.add(case.manual_fact)
                if red=="ninguna" and self.yes("Inspección","¿Sin piezas dobladas, grietas, fugas ni cables atrapados?"): facts.add("sin_dano")
                ok,trace=self.backward.prove("sin_herramientas",facts)
                self.report.add("Encadenamiento hacia atrás",f"Objetivo sin herramientas: {'DEMOSTRADO' if ok else 'NO DEMOSTRADO'}",*trace,"Solo intervención manual limitada; no anula el riesgo." if ok else "Busca transporte, asistencia o taller.")
            years=simpledialog.askfloat("Experiencia","Años reparando bicicletas (0–10):",parent=self.root,minvalue=0,maxvalue=10)
            if years is None: raise InterruptedError
            score,label=self.fuzzy.evaluate(years,tools,complexity)
            self.report.add("Mamdani",f"Experiencia: {years:g} años",f"Herramientas: {self.label(TOOLS,str(tools))}",f"Complejidad: {('Simple','Moderada','Avanzada','Crítica')[complexity]}",f"Facilidad: {score:.1f}/100 — {label.upper()}","Facilidad técnica no equivale a autorización de uso.")
            self.report.add("Conclusión",f"Prioridad: {risk.upper()}",RISK_ACTION[risk],"Conserva códigos, fotos y mediciones para revisión.")
        except InterruptedError:
            messagebox.showinfo("Cancelado","Diagnóstico cancelado.",parent=self.root); return
        except Exception as exc:
            messagebox.showerror("Error",str(exc),parent=self.root); return
        self.show(self.report.render())

    def save(self)->None:
        from tkinter import filedialog,messagebox
        if not self.report.sections: messagebox.showinfo("Sin reporte","Realiza un diagnóstico.",parent=self.root); return
        name=filedialog.asksaveasfilename(parent=self.root,defaultextension=".txt",initialfile=f"diagnostico_{datetime.now():%Y%m%d_%H%M}.txt")
        if name:
            Path(name).write_text(self.report.render(),encoding="utf-8")
            messagebox.showinfo("Guardado","Reporte guardado correctamente.",parent=self.root)
    def copy_report(self)->None:
        from tkinter import messagebox
        if not self.report.sections:
            messagebox.showinfo("Sin reporte","Realiza un diagnóstico.",parent=self.root); return
        self.root.clipboard_clear()
        self.root.clipboard_append(self.report.render())
        self.root.update()
        messagebox.showinfo(
            "Reporte copiado",
            "El reporte quedó en el portapapeles para pegarlo en correo, mensajes o cualquier otra aplicación.",
            parent=self.root,
        )
    def run(self)->None: self.root.mainloop()


def self_test()->None:
    assert len(BIKES)>=18 and len(SCENARIOS)>=45
    assert {"shimano","sram","campagnolo"}<={x for x,_ in BRANDS["transmision"]}
    assert {"fox","rockshox"}<={x for x,_ in BRANDS["suspension"]}
    engine=ScenarioEngine()
    assert engine.infer("frenos","sin_freno").risk=="critico"
    assert engine.infer("electrico","caliente").risk=="critico"
    assert engine.infer("suspension","fuga").complexity==3
    fuzzy=FuzzySystem(); novice=fuzzy.evaluate(0,1,0); pro=fuzzy.evaluate(10,3,1); critical=fuzzy.evaluate(10,3,3)
    assert novice[0]<pro[0] and critical[1]=="Dificil"
    model=BAYES["eje"]; assert bayes_update(model,True)[0]>model.prior>bayes_update(model,False)[0]
    backward=Backward(); assert backward.prove("sin_herramientas",{"cadena_salida","detenida","sin_dano"})[0]
    assert not backward.prove("sin_herramientas",{"freno_roto","detenida"})[0]
    assert "velocidades" in " ".join(compatibility("transmision","shimano","Deore M6100"))
    report=Report(); report.add("Profesional","MTB","RockShox"); assert "RockShox" in report.render()
    print(f"OK: {len(SCENARIOS)} escenarios, {len(BIKES)} tipos y {sum(len(v) for v in BRANDS.values())} opciones de fabricante.")


def main()->None:
    parser=argparse.ArgumentParser(description=__doc__); parser.add_argument("--self-test",action="store_true")
    if parser.parse_args().self_test: self_test()
    else: App().run()


if __name__=="__main__": main()
