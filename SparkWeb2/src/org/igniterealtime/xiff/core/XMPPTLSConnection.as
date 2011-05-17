/*
 * Copyright (C) 2003-2010 Igniterealtime Community Contributors
 *
 *     Daniel Henninger
 *     Derrick Grigg <dgrigg@rogers.com>
 *     Juga Paazmaya <olavic@gmail.com>
 *     Nick Velloff <nick.velloff@gmail.com>
 *     Sean Treadway <seant@oncotype.dk>
 *     Sean Voisen <sean@voisen.org>
 *     Mark Walters <mark@yourpalmark.com>
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.igniterealtime.xiff.core
{
    import com.hurlant.crypto.tls.*;

    import flash.errors.IOError;
    import flash.events.*;
    import flash.xml.XMLNode;

    import org.igniterealtime.xiff.events.*;

    /**
     * TLS supporting connection. You need to have <a href="http://code.google.com/p/as3crypto/">AS3Crypto library</a>
     * in order to use this class.
     *
     * <p>Work in progress. Not expected to work.</p>
     *
     * @see org.igniterealtime.xiff.core.XMPPConnection
     */
    public class XMPPTLSConnection extends XMPPConnection
    {
        private var _config : TLSConfig;
        private var _tlsSocket : TLSSocket;

        private var _tlsRequired : Boolean = false;
        private var _tlsEnabled : Boolean = false;

        public function XMPPTLSConnection()
        {
            super();
        }

        /**
         * @see com.hurlant.crypto.tls.TLSSocket
         */
        private function configureTLSSocket() : void
        {
            _tlsSocket = new TLSSocket();
            _tlsSocket.addEventListener(Event.CLOSE, socketClosed);
            _tlsSocket.addEventListener(Event.CONNECT, socketConnected);
            _tlsSocket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            _tlsSocket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataReceived);
            _tlsSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            _tlsSocket.addEventListener(TLSSocket.ACCEPT_PEER_CERT_PROMPT, onAcceptPeerCertPrompt);
            if (_config != null)
            {
                _tlsSocket.setTLSConfig(_config);
            }
        }

        override public function connect(streamType : uint = 0) : Boolean
        {
            // check if a TLS socket is active (reconnect)
            if (_tlsEnabled)
            {
                // reset
                removeTLSSocketEventListeners();
                _tlsEnabled = false;
            }

            // check if socket is active (reconnect)
            if (active)
            {
                removeSocketEventListeners();
                active = false;
            }

            // reset
            loggedIn = false;

            // create socket, add event listeners
            createSocket();

            _streamType = streamType;
            chooseStreamTags(streamType);

            socket.connect(server, port);

            return true;
        }

        override public function disconnect() : void
        {
            if (isActive())
            {
                sendXML(closingStreamTag);

                // reset
                active = false;
                loggedIn = false;

                try
                {
                    if (_tlsEnabled)
                    {
                        this.removeTLSSocketEventListeners();
                        _tlsSocket.close();
                    }
                    else
                    {
                        this.removeSocketEventListeners();
                        socket.close();
                    }
                }
                catch (e : IOError)
                {
                    dispatchError("service-unavailable", "Service Unavailable", "cancel", 503);
                }

                var disconnectionEvent : DisconnectionEvent = new DisconnectionEvent();
                dispatchEvent(disconnectionEvent);
            }
        }

        protected override function handleStreamFeatures(node : XMLNode) : void
        {
            if (loggedIn)
            {
                bindConnection();
            }
            else
            {
                for each(var feature : XMLNode in node.childNodes)
                {
                    if (feature.nodeName == 'starttls')
                    {
                        handleStreamTLS(feature);
                    }
                    else if (feature.nodeName == 'mechanisms')
                    {
                        configureAuthMechanisms(feature);
                    }
                    else if (feature.nodeName == 'compression')
                    {
                        // zlib is the most common and the one which is required to be implemented.
                        if (_compress)
                        {
                            configureStreamCompression();
                        }
                    }
                }

                // Authenticate only after the possible compression
                // Authenticate only after the possible TLS encoding negotiation.
                // TODO improve robustness of this complex check
                if (((_tlsEnabled && _tlsRequired) || !_tlsRequired) && ((compress && compressionNegotiated) || !compress))
                {
                    // TODO: Why is the username required here but it is not used at the backend?
                    if (useAnonymousLogin || (username != null && username.length > 0))
                    {
                        beginAuthentication();
                    }
                    else
                    {
                        getRegistrationFields();
                    }
                }
            }
        }

        protected override function handleStreamTLS(node : XMLNode) : void
        {
            if (node.firstChild && node.firstChild.nodeName == 'required') //if the user did not turn it on but the server needs it
            {
                _tlsRequired = true;
            }

            //if the user turned it on on the Client. If you are here the server offers TLS.
            if (_tlsRequired)
            {
                this.sendXML("<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls' />");
            }
        }

        protected override function handleNodeType(node : XMLNode) : void
        {
            var nodeName : String = node.nodeName.toLowerCase();
            //<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls' />
            //<proceed xmlns='urn:ietf:params:xml:ns:xmpp-tls'  />
            switch (nodeName)
            {
                case 'proceed':
                    startTLS();
                    break;

                default:
                    super.handleNodeType(node);
                    break;
            }
        }

        protected function startTLS() : void
        {
            // remove listeners from non-TLS socket
            removeSocketEventListeners();

            // add listeners to TLS socket
            configureTLSSocket();

            _tlsSocket.startTLS(socket, this.server);

            // overwrite super
            socket = _tlsSocket;

            _tlsEnabled = true;

            // we have tls. The socket is now wrapped as a TLSSocket
            // Create a new stream and continue
            sendXML(openingStreamTag);
        }

        /**
         *
         * @param    event
         */
        private function onAcceptPeerCertPrompt(event : Event) : void
        {
            trace('onAcceptPeerCertPrompt', event.toString());
        }

        protected function removeTLSSocketEventListeners() : void
        {
            _tlsSocket.removeEventListener(Event.CONNECT, socketConnected);
            _tlsSocket.removeEventListener(Event.CLOSE, socketClosed);
            _tlsSocket.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataReceived);
            _tlsSocket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
            _tlsSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            _tlsSocket.removeEventListener(TLSSocket.ACCEPT_PEER_CERT_PROMPT, onAcceptPeerCertPrompt);
        }

        protected function removeSocketEventListeners() : void
        {
            socket.removeEventListener(Event.CONNECT, socketConnected);
            socket.removeEventListener(Event.CLOSE, socketClosed);
            socket.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataReceived);
            socket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
            socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
        }

        /**
         * TLS configuration. Set after creating the socket.
         */
        public function get config() : TLSConfig
        {
            return _config;
        }

        public function set config(value : TLSConfig) : void
        {
            _config = value;
            if (_tlsSocket != null && _config != null)
            {
                // TODO this might not be a good idea when the socket is active
                _tlsSocket.setTLSConfig(_config);
            }
        }

        public function set tls(tlsBool : Boolean) : void
        {
            _tlsRequired = tlsBool;
        }

        public function get tls() : Boolean
        {
            return _tlsRequired;
        }
    }
}
