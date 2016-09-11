import requests, os, glob, time, json

FMESERVERAPI=os.getenv('FMESERVERAPI', 'secret')
FMEAPI=os.getenv('FMEAPI', 'secret')

# TODO: How to remove tokens here and move to Jenkins / local file?

print("Starting server")
auth = {'Authorization': 'bearer {FMESERVERAPI}'.format(FMESERVERAPI=FMESERVERAPI)}
url = 'https://api.fmecloud.safe.com/v1/instances/2379'

res = requests.get(url, headers=auth)
res.raise_for_status()
if res.json()['state'] != 'RUNNING':
    url = 'https://api.fmecloud.safe.com/v1/instances/2379/start'
    server_res = requests.put(url, headers=auth)
    server_res.raise_for_status()

    sleep = 10
    url = 'https://api.fmecloud.safe.com/v1/instances/2379'
    while True:
        res = requests.get(url, headers=auth)
        res.raise_for_status()
        if res.json()['state'] == 'RUNNING':
            break
        print("Waiting for server to start, sleeping for {} seconds".format(sleep))
        time.sleep(sleep)

print("Server started")
print("Waiting for DNS availability of server")
time.sleep(120)
print("Continuing")

#
# Step 1: Upload the GML files
#

server='bgt-datapunt.fmecloud.com'
auth={'Authorization': 'fmetoken token={FMEAPI}'.format(FMEAPI=FMEAPI)}
urlconnect='fmerest/v2/resources/connections'

# delete directory
url = 'https://{server}/{urlconnect}/FME_SHAREDRESOURCE_DATA/filesys/Import_GML?detail=low'.format(
    server=server, urlconnect=urlconnect)
repository_res = requests.delete(url, headers=auth)
repository_res.raise_for_status()
print("Directory deleted")

# create directory
url = 'https://{server}/{urlconnect}/FME_SHAREDRESOURCE_DATA/filesys/?detail=low'.format(
    server=server, urlconnect=urlconnect)
body = {
    'directoryname': 'Import_GML',
    'type': 'DIR',
}
repository_res = requests.post(url, data=body, headers=auth)
repository_res.raise_for_status()
print("Directory created")

# upload files
url = 'https://{server}/{urlconnect}/FME_SHAREDRESOURCE_DATA/filesys/Import_GML?createDirectories=false&detail=low&overwrite=false'.format(
    server=server, urlconnect=urlconnect)
path = 'data'
for infile in glob.glob(os.path.join('..', path, '*.*')):
    with open(infile,'rb') as f:
        filename = os.path.split(infile)[-1]
        headers = {
            'Content-Disposition': 'attachment; filename="{}"'.format(filename),
            'Content-Type': 'application/octet-stream',
            'Authorization': 'fmetoken token={FMEAPI}'.format(FMEAPI=FMEAPI),
        }
        print('Uploading',infile,'to',filename)
        repository_res = requests.post(url, data=f, headers=headers)
        repository_res.raise_for_status()

#
# Step 2: Start Transformation Job
#
urltransform='fmerest/v2/transformations'

def start_transformation(repository, workspace):
    target_url = 'https://{server}/{urltransform}/commands/submit/{repository}/{workspace}'.format(
        server=server, urltransform=urltransform, repository=repository, workspace=workspace)

    try:
        response = requests.post(
            url=target_url,
            params={
                "detail": "low",
            },
            headers={
                "Referer": "https://bgt-datapunt.fmecloud.com/fmerest/v2/apidoc/",
                "Origin": "https://bgt-datapunt.fmecloud.com",
                "Authorization": "fmetoken token={FMEAPI}".format(FMEAPI=FMEAPI),
                "Content-Type": "application/json",
                "Accept": "application/json",
            },

            data=json.dumps({
                "subsection": "REST_SERVICE",
                "FMEDirectives": {

                },
                "NMDirectives": {
                    "successTopics": [

                    ],
                    "failureTopics": [

                    ]
                },
                "TMDirectives": {
                    "priority": 5,
                    "tag": "linux",
                    "description": "This is my description"
                },
                "publishedParameters": [
                    {
                        "name": "DestDataset_POSTGIS_4",
                        "value": "db_cloud"
                    },
                    {
                        "name": "CITYGML_IN_ADE_XSD_DOC_CITYGML",
                        "value": [
                            "$(FME_SHAREDRESOURCE_DATA)/imgeo.xsd"
                        ]
                    },
                    {
                        "name": "SourceDataset_CITYGML",
                        "value": [
                            "$(FME_SHAREDRESOURCE_DATA)/Import_GML/*.gml"
                        ]
                    }
                ]
            })
        )

        print('Response HTTP Status Code: {status_code}'.format(status_code=response.status_code))
        print('Response HTTP Response Body: {content}'.format(content=response.content))

        res = response.json()
        return res['id']

    except requests.exceptions.RequestException:
        print('HTTP Request failed')


if __name__ == '__main__':
    print("Running")
    jobid = start_transformation('BGT', 'inlezen_DB_BGT_uit_citygml.fmw')
    print('Job started! Job ID: {}'.format(jobid))


# Step 3: Now wait for the job to be completed
print("Wait 2 hours until polling for completion")
time.sleep(7200)
print("2 hours have passed, now checking every 5 minutes")
sleep = 300
url = 'https://{server}/{urltransform}/jobs/id/{jobid}/result?detail=low'.format(
    server=server, urltransform=urltransform, jobid=jobid)

while True:
    res = requests.get(url, headers=auth)
    res.raise_for_status()
    if res.json()['status'] == 'SUCCESS':
        break
    print("Still processing, sleeping for {}".format(sleep))
    time.sleep(sleep)

print("Job completed!")


