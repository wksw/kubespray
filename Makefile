mitogen:
	@echo Mitogen support is deprecated.
	@echo Please run the following command manually:
	@echo   ansible-playbook -c local mitogen.yml -vv
clean:
	rm -rf dist/
	rm *.retry

update: ## 更新submodule
	# 更新本地gitmodules中URL配置
	git submodule sync
	git submodule foreach --recursive git reset --hard 
	git submodule foreach --recursive git clean -fdx
	# 初始化并更新,并自动进入子仓库拉取并更新
	git submodule update --init --remote --recursive
	git submodule foreach  --recursive 'tag="$$(git config -f $$toplevel/.gitmodules submodule.$$name.tag)";[ -n $$tag ] && git tag -d $$tag && git fetch origin -t -f  && git reset --hard  $$tag'

install: ## 安装集群
	docker pull quay.io/kubespray/kubespray:v2.24.1
	docker run --rm -it --mount type=bind,source="$(PWD)"/inventory/sample,dst=/inventory \
		--mount type=bind,source="$(HOME)"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
		quay.io/kubespray/kubespray:v2.24.1 \
		ansible-playbook -i /inventory/inventory.ini --private-key /root/.ssh/id_rsa cluster.yml