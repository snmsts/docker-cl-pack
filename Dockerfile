FROM docker-cl-pack.pack
COPY home/app /bin
EXPOSE 8000
WORKDIR /home/user
USER user
ENTRYPOINT ["app"]
