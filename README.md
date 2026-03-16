# Agent Engine 실습 및 Gemini Enterprise 연동
-   https://github.com/cheeunlim/agent-engine-lab

Google Cloud의 Agent Engine 실습에 사용되는 데모 프로젝트 입니다.

Agent 예제는 ['Dietary_Planner'](https://medium.com/google-cloud/diatery-planner-your-ai-powered-recipe-diet-planner-with-googles-adk-5c402802c094)를 참고했습니다. 

Agent Starter Pack은 다음을 참고합니다. [`googleCloudPlatform/agent-starter-pack`](https://github.com/GoogleCloudPlatform/agent-starter-pack) version `0.16.0`

DB Session 을 이용시 Private network 에서의 DB 배포는 아래 메뉴얼을 따릅니다.

https://cloud.google.com/sql/docs/postgres/configure-private-service-connect?hl=ko

## Project Structure

폴더 구조는 아래를 따릅니다.:

```
agent-engine-test/
├── app/                 # Main application code
│   ├── agent.py         # Main agent (Root agent)
│   ├── sub_agents/      # Sub agent
│   ├── agent_engine_app.py # Agent Engine start code
│   └── utils/           # Utility functions and helpers
├── .cloudbuild/         # CI/CD pipeline configurations for Google Cloud Build
├── deployment/          # Infrastructure and deployment scripts
├── notebooks/           # Jupyter notebooks for prototyping and evaluation
├── tests/               # Unit, integration, and load tests
├── Makefile             # Makefile for common commands
├── GEMINI.md            # AI-assisted development guide
└── pyproject.toml       # Project dependencies and configuration
```

## Quick Start - Local 테스트

로컬 환경에서는 아래의 명령으로 테스트 환경(adk web)을 실행할 수 있습니다.

```bash
make install && make playground
```

## Quick Start - Agent Engine 으로 테스트 배포(DEV)

현재 프로젝트를 테스트 목적으로 Agent Engine 에 배포하고자 한다면 아래의 명령어를 실행 합니다.

```bash
make backend
```

## Quick Start - Agent Engine 으로 CI/CD 환경 구축(STG/PRD)

현재 프로젝트를 Agent Engine 으로 CI/CD 시스템을 구축하고자 한다면 아래의 명령어를 실행 합니다.

STG와 PRD 환경은 서로 다른 프로젝트를 이용해야 합니다.

```bash
agent-starter-pack setup-cicd --cicd-project [CI/CD 를 수행할 프로젝트ID] --staging-project [STG 환경 프로젝트ID] --prod-project [PRD 환경 프로젝트ID] --repository-name [리포지토리명]
```

## Commands

| 명령어                | 설명                                                                            |
| -------------------- | --------------------------------------------------------------------------------|
| `make install`       | uv 를 이용해 필요한 패키지를 설치합니다.                                           |
| `make playground`    | Agent 를 로컬에서 테스트할 수 있는 UI를 실행합니다. 좌측 상단에서 App을 선택합니다.  |
| `make backend`       | 현재의 구성을 Agent Engine 으로 배포합니다.                                        |
| `make test`          | 유닛 테스트와 통합 테스트를 수행합니다.                                            |
| `make lint`          | 코드 품질 체크를 실행합니다. (codespell, ruff, mypy)                              |
| `git push`           | CI/CD 파이프라인을 수행합니다.                                                    |

<br>
<br>
<br>
<br>

# Qwiklab 실습

## 📍 실습 Part 1

아래 내용은 Qwiklab 환경을 통해 구성한 Google Cloud의 Vertex AI Workbench에서 실습을 진행하는 방법을 다루고 있습니다.

#### 1. 상단 검색 메뉴에서 'workbench' 를 입력하여 'Workbench' 메뉴를 클릭합니다.
![image](https://raw.githubusercontent.com/jk1333/handson/main/images/6/1.png)
***
<br>

#### 2. 'Open Jupyterlab' 버튼을 눌러 환경에 접속합니다.
![image](https://raw.githubusercontent.com/cheeunlim/agent-engine-lab/main/images/workbench_open.png)

실행된 창에서 Terminal에 진입 후 아래 명령어로 실습자료를 다운로드 받습니다.

```
git clone https://github.com/cheeunlim/agent-engine-lab
```

#### 3. 실습 자료 다운로드가 완료된 후 아래 명령어로 예제 에이전트를 Agent Engine에 배포합니다.

```
pip install uv
cd agent-engine-lab
make backend
```
<br>

#### 🚨 **배포가 완료될 때까지 10여분의 시간이 소요됩니다.** 
<br>

## 📍 실습 Part 2

#### 9. Google Cloud 콘솔의 좌측 메뉴에서 Agent Engine 을 클릭합니다.

![image](https://raw.githubusercontent.com/jk1333/handson/main/images/6/3.png)
***
<br>

#### 10. 배포된 Agent Engine 을 확인 후 Resource name을 복사해 메모장에 기록하고, Agent를 클릭합니다.

![image](https://raw.githubusercontent.com/jk1333/handson/main/images/6/5.png)
***
<br>

#### 11. Playground 메뉴에 들어가서 다양한 대화를 해봅니다.

Session 1 예시: 근량 증가를 위한 저녁 메뉴를 추천해주세요.

Session 2 예시: 저는 채식주의자 입니다.

Session 3 예시: 소고기 메뉴를 추천해 주세요. 

(기대결과: 채식주의자라고 말씀해주셨기 때문에 이에 맞는 메뉴로 추천드립니다.)

![image](https://raw.githubusercontent.com/jk1333/handson/main/images/6/6.png)
***
<br>

#### 12. 다양한 대화를 수행해본 후 Memories 메뉴에 접속하여 발화 내용이 메모리에 추가되었는지 확인합니다.

![image](https://raw.githubusercontent.com/jk1333/handson/main/images/6/7.png)
***
<br>

#### 13. Dashboard, Traces, Sessions 메뉴를 클릭하며 각 기능을 살펴봅니다.

## 📍 실습 Part 3

#### 4. Google Cloud 콘솔 검색 메뉴에서 "credentials" 혹은 "oauth" 를 검색하면 나오는 Credentials 를 클릭합니다.
![image](https://raw.githubusercontent.com/jk1333/handson/main/images/6/8.png)
***
<br>

Create credentials -> OAuth client ID 를 클릭합니다.

Application type: Web application

Name: ge-cred (혹은 임의의 값)

Authorized redirect URI 는 다음을 입력 후 Create합니다.

```
https://vertexaisearch.cloud.google.com/oauth-redirect
```

#### 🚨 **Create를 누른 후 뜨는 팝업창이 뜰 때까지 반드시 대기합니다.** 
해당 창이 닫힌 후 Client Secret 값을 다시 가져올 수 없으므로, Credential을 새로 생성해야 합니다.

![image](https://raw.githubusercontent.com/cheeunlim/agent-engine-lab/main/images/oauth_client.png)
***
<br>

팝업 창의 CLIENT_ID, CLIENT_SECRET 값을 따로 기록하거나, Download JSON을 클릭해 파일로 저장합니다.

#### 5. Google Cloud 콘솔에서 Gemini Enterprise 를 검색 후 메뉴로 진입합니다.

![image](https://raw.githubusercontent.com/jk1333/handson/main/images/6/11.png)
***
<br>

#### 6. Authentication Settings
Gemini Enterprise 메뉴의 Settings 로 진입하여 Authentication settings 부분에 global 설정메뉴 진입 후 Google Identity 를 설정합니다.

![image](https://raw.githubusercontent.com/jk1333/handson/main/images/6/12.png)
***
<br>

#### 7. Calendar 데이터 스토어 생성
Apps를 클릭 후 기 생성돼 있는 agent-portal 을 클릭합니다. 
Connected data stores 를 클릭한 후, New data store > Google Drive 를 클릭합니다.

![image](https://raw.githubusercontent.com/cheeunlim/agent-engine-lab/main/images/cal_connector.png)
***

4번 태스크에서 생성한 Credential 정보(ID, Secret)을 입력하고, Create calendar event 및 Update calendar event를 모두 활성화한 후 Continue 버튼을 클릭합니다. 
'calendar' 혹은 임의의 이름을 입력해준 후 create 버튼을 눌러 생성합니다.

![image](https://raw.githubusercontent.com/cheeunlim/agent-engine-lab/main/images/cal_connector_config.png)
***

#### 8. 배포 완료 시 아래와 같은 "Active" 상태를 확인합니다.

![image](https://raw.githubusercontent.com/cheeunlim/agent-engine-lab/main/images/cal_connector_created.png)
***
<br>


#### 14. 앞서 기록한 Credential 정보와 Agent Engine 의 Resource Name을 Makefile에 업데이트 합니다.

Jupyter Lab 에서 /agent-engine-lab/Makefile 을 열어 아래 정보를 확인 후 기록해둔 값으로 업데이트 합니다.

```
CLIENT_ID := CLIENT_ID
CLIENT_SECRET := SECRET
AGENT_ENGINE_RESOURCE_NAME := FULL_RESOURCE_NAME
```

![image](https://raw.githubusercontent.com/jk1333/handson/main/images/6/10.png)
***
<br>

#### 15. Jupyter Lab 의 Terminal 로 돌아와 아래의 명령어를 실행하여 에이전트를 Gemini Enterprise에 등록합니다.

```
make ge-register
```

#### 16. Gemini Enterprise 를 실행합니다.

![image](https://raw.githubusercontent.com/jk1333/handson/main/images/6/14.png)
***
<br>

#### 17. 메인 대화창에서 '@' 기호를 입력한 후, 'Dietary Planner'를 선택한 후 텍스트를 입력하여 대화를 시작합니다.

![image](https://raw.githubusercontent.com/cheeunlim/agent-engine-lab/main/images/agent_select.png)
***
<br>

Authorize 버튼을 클릭해 접근 권한을 부여합니다.

![image](https://raw.githubusercontent.com/jk1333/handson/main/images/6/16.png)
***
<br>


#### 18. 캘린더 이벤트 생성을 수행하기 위해 채팅창 하단의 커넥터 버튼을 클릭한 후, Calendar의 'Enable actions'를 클릭합니다. 

태스크 17과 동일한 방법으로, 사용자 캘린더 권한을 부여합니다.

![image](https://raw.githubusercontent.com/cheeunlim/agent-engine-lab/main/images/connector_auth.png)
<br>

#### 19. 캘린더 이벤트 생성 대화를 위해 'Dietary Planner' 에이전트를 잠시 꺼둡니다. 

![image](https://raw.githubusercontent.com/cheeunlim/agent-engine-lab/main/images/toggle_agent.png)

캘린더 이벤트 생성을 확정합니다.

![image](https://raw.githubusercontent.com/cheeunlim/agent-engine-lab/main/images/confirm_cal_event.png)
<br>

#### 20. [Google Calendar](https://calendar.google.com/)에 접속하여 일정이 생성되었음을 확인합니다.

![image](https://raw.githubusercontent.com/cheeunlim/agent-engine-lab/main/images/google_cal.png)
<br>

<br>
## 🏁 실습 완료! 