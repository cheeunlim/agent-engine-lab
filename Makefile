
# ==============================================================================
# Installation & Setup
# ==============================================================================

# Install dependencies using uv package manager
install:
	@command -v uv >/dev/null 2>&1 || { echo "uv is not installed. Installing uv..."; curl -LsSf https://astral.sh/uv/0.8.13/install.sh | sh; source $HOME/.local/bin/env; }
	uv sync

# ==============================================================================
# Playground Targets
# ==============================================================================

# Launch local dev playground
playground:
	@echo "==============================================================================="
	@echo "| 🚀 Starting your agent playground...                                        |"
	@echo "|                                                                             |"
	@echo "| 💡 Try asking: What's the weather in San Francisco?                         |"
	@echo "|                                                                             |"
	@echo "| 🔍 IMPORTANT: Select the 'app' folder to interact with your agent.          |"
	@echo "==============================================================================="
	uv run adk web . --port 8501 --reload_agents

# ==============================================================================
# Backend Deployment Targets
# ==============================================================================

# Deploy the agent remotely
# Usage: make deploy [AGENT_IDENTITY=true] [SECRETS="KEY=SECRET_ID,..."] - Set AGENT_IDENTITY=true to enable per-agent IAM identity (Preview)
deploy:
	# Export dependencies to requirements file using uv export.
	(uv export --no-hashes --no-header --no-dev --no-emit-project --no-annotate > app/app_utils/.requirements.txt 2>/dev/null || \
	uv export --no-hashes --no-header --no-dev --no-emit-project > app/app_utils/.requirements.txt) && \
	uv run -m app.app_utils.deploy \
		--location="us-central1" \
		--model-location="global" \
		--source-packages=./app \
		--entrypoint-module=app.agent_engine_app \
		--entrypoint-object=agent_engine \
		--requirements-file=app/app_utils/.requirements.txt \
		$(if $(AGENT_IDENTITY),--agent-identity) \
		$(if $(filter command line,$(origin SECRETS)),--set-secrets="$(SECRETS)")

# Alias for 'make deploy' for backward compatibility
backend: deploy

# ==============================================================================
# Testing & Code Quality
# ==============================================================================

# Run unit and integration tests
test:
	uv sync --dev
	uv run pytest tests/unit && uv run pytest tests/integration

# ==============================================================================
# Agent Evaluation
# ==============================================================================

# Run agent evaluation using ADK eval
# Usage: make eval [EVALSET=tests/eval/evalsets/basic.evalset.json] [EVAL_CONFIG=tests/eval/eval_config.json]
eval:
	@echo "==============================================================================="
	@echo "| Running Agent Evaluation                                                    |"
	@echo "==============================================================================="
	uv sync --dev --extra eval
	uv run adk eval ./app $${EVALSET:-tests/eval/evalsets/basic.evalset.json} \
		$(if $(EVAL_CONFIG),--config_file_path=$(EVAL_CONFIG),$(if $(wildcard tests/eval/eval_config.json),--config_file_path=tests/eval/eval_config.json,))

# Run evaluation with all evalsets
eval-all:
	@echo "==============================================================================="
	@echo "| Running All Evalsets                                                        |"
	@echo "==============================================================================="
	@for evalset in tests/eval/evalsets/*.evalset.json; do \
		echo ""; \
		echo "▶ Running: $$evalset"; \
		$(MAKE) eval EVALSET=$$evalset || exit 1; \
	done
	@echo ""
	@echo "✅ All evalsets completed"

# Run code quality checks (codespell, ruff, ty)
lint:
	uv sync --dev --extra lint
	uv run codespell
	uv run ruff check . --diff
	uv run ruff format . --check --diff
	uv run ty check .

# ==============================================================================
# Gemini Enterprise Integration
# ==============================================================================
CLIENT_ID := CLIENT_ID
CLIENT_SECRET := SECRET
AGENT_ENGINE_RESOURCE_NAME := FULL_RESOURCE_NAME
GEMINI_ENTERPRISE_APP_ID := APPLICATION_ID

AUTH_ID_TO_USE := dietary_planner
GEMINI_ENTERPRISE_REGION := global

ge-register:
	$(eval PROJECT_ID := $(shell gcloud config get-value project))
	$(eval PROJECT_NUMBER := $(shell gcloud projects describe $(PROJECT_ID) --format='value(projectNumber)'))
	$(eval ACCESS_TOKEN := $(shell gcloud auth print-access-token))

	@echo "기존 Agent ID를 가져오는 중..."; \
	AGENT_ID=$$(curl -s -H "Authorization: Bearer $(ACCESS_TOKEN)" -H "Content-Type: application/json" -H "X-Goog-User-Project: $(PROJECT_ID)" "https://${GEMINI_ENTERPRISE_REGION}-discoveryengine.googleapis.com/v1alpha/projects/${PROJECT_ID}/locations/${GEMINI_ENTERPRISE_REGION}/collections/default_collection/engines/${GEMINI_ENTERPRISE_APP_ID}/assistants/default_assistant/agents" | jq -r '.agents[] | select(.displayName == "Dietary Planner") | .name | split("/") | last'); \
    echo "추출된 Agent ID: $$AGENT_ID"; \
	if [ -n "$$AGENT_ID" ] && [ "$$AGENT_ID" != "null" ]; then \
		echo "추출된 Agent ID ($$AGENT_ID)를 찾았습니다. 삭제를 진행합니다."; \
		\
		echo "[1/2] Agent 삭제 중..."; \
		curl -X DELETE \
			-H "Authorization: Bearer $(ACCESS_TOKEN)" \
			"https://${GEMINI_ENTERPRISE_REGION}-discoveryengine.googleapis.com/v1alpha/projects/$(PROJECT_ID)/locations/${GEMINI_ENTERPRISE_REGION}/collections/default_collection/engines/${GEMINI_ENTERPRISE_APP_ID}/assistants/default_assistant/agents/$$AGENT_ID"; \
		\
		echo "\n[2/2] Authorization 삭제 중..."; \
		curl -X DELETE \
			-H "Authorization: Bearer $(ACCESS_TOKEN)" \
			-H "X-Goog-User-Project: $(PROJECT_ID)" \
			"https://$(GEMINI_ENTERPRISE_REGION)-discoveryengine.googleapis.com/v1alpha/projects/$(PROJECT_ID)/locations/$(GEMINI_ENTERPRISE_REGION)/authorizations/$(AUTH_ID_TO_USE)"; \
		\
		echo "\n삭제 프로세스가 완료되었습니다."; \
	else \
		echo "조건에 맞는 'Dietary Planner' Agent를 찾을 수 없습니다. 삭제를 건너뜁니다."; \
	fi

	@echo "1. Authorizations 등록 중..."
	curl -X POST \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" \
		-H "Content-Type: application/json" \
		-H "X-Goog-User-Project: $(PROJECT_ID)" \
		"https://$(GEMINI_ENTERPRISE_REGION)-discoveryengine.googleapis.com/v1alpha/projects/$(PROJECT_ID)/locations/$(GEMINI_ENTERPRISE_REGION)/authorizations?authorizationId=$(AUTH_ID_TO_USE)" \
		-d '{"name": "projects/$(PROJECT_NUMBER)/locations/$(GEMINI_ENTERPRISE_REGION)/authorizations/$(AUTH_ID_TO_USE)", "serverSideOauth2": {"clientId": "$(CLIENT_ID)", "clientSecret": "$(CLIENT_SECRET)", "authorizationUri": "https://accounts.google.com/o/oauth2/v2/auth?client_id=$(CLIENT_ID)&redirect_uri=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Fstatic%2Foauth%2Foauth.html&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform&include_granted_scopes=true&response_type=code&access_type=offline&prompt=consent", "tokenUri": "https://oauth2.googleapis.com/token"}}'

	@echo "\n2. Agent 등록 중..."
	curl -X POST \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" \
		-H "Content-Type: application/json" \
		-H "X-Goog-User-Project: $(PROJECT_ID)" \
		"https://$(GEMINI_ENTERPRISE_REGION)-discoveryengine.googleapis.com/v1alpha/projects/$(PROJECT_ID)/locations/$(GEMINI_ENTERPRISE_REGION)/collections/default_collection/engines/$(GEMINI_ENTERPRISE_APP_ID)/assistants/default_assistant/agents" \
		-d '{"displayName": "Dietary Planner", "description": "Healthy life", "adk_agent_definition": { "provisioned_reasoning_engine": { "reasoning_engine": "$(AGENT_ENGINE_RESOURCE_NAME)" } }, "authorization_config": {"tool_authorizations": ["projects/$(PROJECT_NUMBER)/locations/$(GEMINI_ENTERPRISE_REGION)/authorizations/$(AUTH_ID_TO_USE)"]}}'


# Register the deployed agent to Gemini Enterprise
# Usage: make register-gemini-enterprise (interactive - will prompt for required details)
# For non-interactive use, set env vars: ID or GEMINI_ENTERPRISE_APP_ID (full GE resource name)
# Optional env vars: GEMINI_DISPLAY_NAME, GEMINI_DESCRIPTION, GEMINI_TOOL_DESCRIPTION, AGENT_ENGINE_ID
register-gemini-enterprise:
	@uvx agent-starter-pack@0.41.3 register-gemini-enterprise