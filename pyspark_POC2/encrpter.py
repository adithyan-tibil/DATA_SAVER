import base64
import os
from Crypto.Cipher import AES

# Encryption parameters
SECRET_KEY = b'k92ldahavl97s428vxri7x89seoy79sm'
INIT_VECTOR = b'7dzhcnrb0016hmj3'

# def encrypt_data(data):
#     cipher = AES.new(SECRET_KEY, AES.MODE_GCM, nonce=INIT_VECTOR)
#     ciphertext, auth_tag = cipher.encrypt_and_digest(data.encode())
#     # Concatenate ciphertext and auth_tag for later decryption
#     encrypted_data = ciphertext + auth_tag
#     return base64.b64encode(encrypted_data).decode()


def encrypt_data(data):
    cipher = AES.new(SECRET_KEY, AES.MODE_GCM, nonce=INIT_VECTOR)
    ciphertext, auth_tag = cipher.encrypt_and_digest(data.encode())
    encrypt_data=base64.b64encode(ciphertext).decode()
    auth_tag=base64.b64encode(auth_tag).decode()
    return encrypt_data,auth_tag


# Example usage
plaintext = '''
<XML>

<MessageType>1200</MessageType>

<ProcCode>$ProcCode$</ProcCode>

<NotificationId>$NotificationId$</NotificationId>

<TargetMobile>$TargetMobile$</TargetMobile>

<TxnType>$TxnType$</TxnType>

<ProfileId>$ProfileId$</ProfileId>

<UpiTranlogId>$UpiTranlogId$</UpiTranlogId>

<ExpireAfter>$ExpireAfter$</ExpireAfter>

<Payee>

<Name>$PayeeName$</Name>

<Mobile>$PayeeMobile$</Mobile>

<VA>$PayeeVA$</VA>

<RespCode>$payeeRespCode$</RespCode>

<MccCode>$payeeMccCode$</MccCode>

<MccType>$payeeMccType$</MccType>

<AccountNo>$payeeAccountNo$</AccountNo>

<Ifsc>823</Ifsc>

<RevRespCode>$payeeRevRespCode$</RevRespCode>

<VerifiedMerchant>$verifiedMerchant$</VerifiedMerchant>

$payeeMid$

</Payee>

<Payer>

<Name>$PayerName$</Name>

<Mobile>$PayerMobile$</Mobile>

<VA>$PayerVA$</VA>

<AccountNo>$payerAccountNo$</AccountNo>

<Ifsc>$ifsc$</Ifsc>

<AccountType>$payerAccountType$</AccountType>

<RespCode>$payerRespCode$</RespCode>

<RevRespCode>$payerRevRespCode$</RevRespCode>

<GstIncentiveApplicable>$GstIncentiveApplicable$</GstIncentiveApplicable>

$payerMid$

</Payer>    

<Amount>7000</Amount>

<ChannelCode>$ChannelCode$</ChannelCode>

<TxnStatus>$TxnStatus$</TxnStatus>

<TxnInitDate>$TxnInitDate$</TxnInitDate>

<TxnCompletionDate>$TxnCompletionDate$</TxnCompletionDate>

<Note>$Note$</Note>

<DeviceId>177418</DeviceId>

<OriginalTxnId>$OriginalTxnId$</OriginalTxnId>

<RefId>$RefId$</RefId>

<RefUrl>$RefUrl$</RefUrl>

<Rrn>$Rrn$</Rrn>

<ResponseCode>$ResponseCode$</ResponseCode>

<NeedPayerGstConsent>$NeedPayerGstConsent$</NeedPayerGstConsent>

<IsFromBlockedVpa>$IsFromBlockedVpa$</IsFromBlockedVpa>

$RiskScores$

<MandateMetadat>

<Umn>$Umn$</Umn>

<SequenceNumber>$SequenceNumber$</SequenceNumber>

</MandateMetadat>

<Gstin>$Gstin$</Gstin>

<Gst>

<Amount>$GstAmount$</Amount>

<Cgst>$CgstAmount$</Cgst>

<Sgst>$SgstAmount$</Sgst>

<Igst>$IgstAmount$</Igst>

<Cess>$CessAmount$</Cess>

</Gst>

<Invoice>

<InvoiceNumber>$InvoiceNumber$</InvoiceNumber>

<InvoiceDate>$InvoiceDate$</InvoiceDate>

<InvoiceUrl>$InvoiceUrl$</InvoiceUrl>

</Invoice>

<payeePspReqTxnConfirmationTime>$payeePspReqTxnConfirmationTime$</payeePspReqTxnConfirmationTime>

<payeePspTxnConfirmationCallbackInitiationTime>$payeePspTxnConfirmationCallbackInitiationTime$</payeePspTxnConfirmationCallbackInitiationTime>

</XML>

'''
encrypted_string = encrypt_data(plaintext)
print(f"Encrypted (Base64): {encrypted_string}")
