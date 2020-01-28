netbox-formula
=======

.. _readme:


Install and configure `Netbox (an IPAM and DCIM tool).
<https://github.com/netbox-community/netbox>`_.


.. contents:: **Table of Contents**

Currently only Ubuntu & Debian is tested

General notes
-------------

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#writing-formulas>`_.

If you want to use this formula, please pay attention to the ``FORMULA`` file and/or ``git tag``,
which contains the currently released version. This formula is versioned according to `Semantic Versioning <http://semver.org/>`_.

See `Formula Versioning Section <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#versioning>`_ for more details.

Available states
----------------

.. contents::
    :local:


``netbox.service``
^^^^^^^^^^^^^^^^


Setup and configure the Netbox Service in a Python Virtualenv, managed by Supervisord

``netbox.www.apache``
^^^^^^^^^^^^^^^^

Install and configure Apache2 as reverse proxy to Netbox

``netbox.www.nginx``
^^^^^^^^^^^^^^^^

Install and configure nginx as reverse proxy to Netbox

``netbox.db``
^^^^^^^^^^^^^^^^

Install Postgres and setup a database + user for Netbox

``netbox.redis``
^^^^^^^^^^^^^^^^

Install Redis-Server

``netbox.optional.napalm``
^^^^^^^^^^^^^^^^

Installs the napalm driver 

``netbox.optional.rfs`
^^^^^^^^^^^^^^^^

Installs packages for remote-file-storage capability

``netbox.autoupgrade``
^^^^^^^^^^^^^^^^

Checkout latest version from git and run upgrade script to keep Netbox updated
