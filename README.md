# Scheduler Server

![](schedy.png)

Scheduler is an application for distributed task execution.

## Built With

- [Rails](https://rubyonrails.org/)
- [mithril.js](https://mithril.js.org/)
- [Bootstrap](https://getbootstrap.com/)
- [Seapig/Hyperpig](https://github.com/yunta-mb/seapig-server)


## Development Setup

### Prerequisites
#### Fedora 30+


```
dnf install podman-compose
```

#### Deployment

scheduler-server should be available at [https://localhost:8000](https://localhost:8000) after containers are running.

```bash
git clone https://github.com/schedy/scheduler-server &&\
cd scheduler-server &&\
podman-compose -f compose/container-compose.yml build &&\
podman-compose -f compose/container-compose.yml up
```


## Testing

```ruby
rspec
```

## Roadmap

- world conquest

##

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.


## License
[MIT](https://choosealicense.com/licenses/mit/)