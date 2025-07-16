import json
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Appointments')

def lambda_handler(event, context):
    customer = event['Details']['ContactData']['CustomerEndpoint']['Address']
    appointment_date = event['Details']['Parameters'].get('AppointmentDate', '2025-08-01')
    appointment_time = event['Details']['Parameters'].get('AppointmentTime', '10:00')
    service = event['Details']['Parameters'].get('ServiceType', 'Consultation')

    table.put_item(Item={
        'PhoneNumber': customer,
        'AppointmentDate': appointment_date,
        'AppointmentTime': appointment_time,
        'Service': service,
        'CreatedAt': datetime.utcnow().isoformat()
    })

    return {
        'statusCode': 200,
        'body': json.dumps('Appointment scheduled successfully!')
    }
