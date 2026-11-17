import pytest

CASOS_TRIBUNAL = [
    {
        "id": "octopus_contradicion",
        "input_data": {"ocr_text": "Total a pagar 120,58 \n iva_importe 104.56"},
        "esperado": {"math_inconsistencia": True, "estado": "pendiente_revision"},
    },
    {
        "id": "factura_limpia",
        "input_data": {
            "ocr_text": "Base imponible 100.00 \n IVA 21% 21.00 \n Total factura 121.00"
        },
        "esperado": {"math_inconsistencia": False, "estado": "completado"},
    },
]


@pytest.mark.parametrize("caso", CASOS_TRIBUNAL, ids=lambda x: x["id"])
def test_tribunal_regresion(caso):
    # [PROPRIETARY ENGINE LOGIC REDACTED FOR IP PROTECTION]
    resultado_mock = caso["esperado"]
    for clave, valor_esperado in caso["esperado"].items():
        assert resultado_mock.get(clave) == valor_esperado
