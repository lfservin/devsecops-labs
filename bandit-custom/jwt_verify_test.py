import bandit
from bandit.core import test_properties as test

@test.checks('Call')
@test.test_id('B350')
def unsafe_jwt_verify(context):
    if (context.call_function_name_qual == 'jwt.decode'):
        if context.get_call_arg_value('verify') == 'False':
            return bandit.Issue(
                severity = bandit.HIGH,
                confidence = bandit.HIGH,
                text = 'JSON Web Token decode() method does not verify the HMAC/Key. Attacker can use this to spoof Authentication Tokens'
            )