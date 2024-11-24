# PGR301 - Eksamen 2024
DevOps eksamen 2024 - kandidatnr 28

## OPPGAVE 1

## OPPGAVE 2
- **Deploy Terraform to main:** [Link to workflow](https://github.com/iMery/pgr301-eksamen/actions/runs/11983546334)
- **Deploy Terraform to other branches:** [Link to workflow](https://github.com/iMery/pgr301-eksamen/actions/runs/11983812264)
- **SQS URL:** [https://sqs.eu-west-1.amazonaws.com/244530008913/maqueue01](https://sqs.eu-west-1.amazonaws.com/244530008913/maqueue01)
  
## OPPGAVE 3
Jeg valgte "latest" som tag fordi det sikrer at brukerne alltid får den nyeste versjonen uten å måtte spesifisere en versjon. Dette gjør integrasjonen enkel og sørger for at oppdateringer kan publiseres raskt under aktiv utvikling, noe som passer for applikasjoner som behandler SQS-forespørsler og genererer bilder i en S3-bucket.

**Container image + SQS URL:**
- **Container image:** `maka082/java-sqs-client`
- **SQS URL:** [https://sqs.eu-west-1.amazonaws.com/244530008913/maqueue01](https://sqs.eu-west-1.amazonaws.com/244530008913/maqueue01)

## OPPGAVE 4 

## OPPGAVE 5
